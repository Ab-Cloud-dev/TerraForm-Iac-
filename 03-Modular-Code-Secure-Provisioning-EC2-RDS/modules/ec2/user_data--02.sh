#!/bin/bash
yum update -y
yum install -y httpd php php-mysqli  jq
sudo dnf install mariadb105 -y
# Install AWS CLI v2
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Start Apache
systemctl start httpd
systemctl enable httpd

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Store variables
SECRET_ARN="${secret_arn}"
REGION="${region}"

# Create PHP config
cat > /var/www/html/db_config.php << 'EOF'
<?php
function getDBConnection() {
    $secretArn = trim(file_get_contents('/tmp/secret_arn'));
    $region = trim(file_get_contents('/tmp/region'));
    
    $command = sprintf('aws secretsmanager get-secret-value --secret-id %s --region %s --query SecretString --output text',
        escapeshellarg($secretArn), escapeshellarg($region));
    
    $secretJson = shell_exec($command);
    if (!$secretJson) throw new Exception("Failed to get credentials");
    
    $creds = json_decode(trim($secretJson), true);
    if (!$creds) throw new Exception("Invalid credentials format");
    
    $mysqli = new mysqli(
        $creds['host'] ?? 'localhost',
        $creds['username'] ?? 'admin', 
        $creds['password'] ?? '',
        $creds['dbname'] ?? 'appdb',
        $creds['port'] ?? 3306
    );
    
    if ($mysqli->connect_error) {
        throw new Exception("Connection failed: " . $mysqli->connect_error);
    }
    
    return $mysqli;
}
?>
EOF

# Store secret info
echo "$SECRET_ARN" > /tmp/secret_arn
echo "$REGION" > /tmp/region

# Create main application
cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Simple RDS Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .nav { margin: 20px 0; }
        .nav a { margin-right: 20px; text-decoration: none; color: #007cba; }
        .success { background: #d4edda; color: #155724; padding: 10px; margin: 10px 0; }
        .error { background: #f8d7da; color: #721c24; padding: 10px; margin: 10px 0; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        input, textarea { width: 200px; padding: 5px; }
        button { padding: 8px 16px; background: #007cba; color: white; border: none; }
    </style>
</head>
<body>
    <h1>Simple RDS Demo</h1>
    <div class="nav">
        <a href="?page=add">Add Entry</a>
        <a href="?page=view">View Entries</a>
        <a href="?page=info">System Info</a>
    </div>

    <?php
    require_once 'db_config.php';
    $page = $_GET['page'] ?? 'add';
    
    try {
        $mysqli = getDBConnection();
        
        // Create table
        $mysqli->query("CREATE TABLE IF NOT EXISTS entries (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            message TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )");
        
        if ($page == 'add') {
            if (isset($_POST['name']) && $_POST['name']) {
                $name = $mysqli->real_escape_string($_POST['name']);
                $message = $mysqli->real_escape_string($_POST['message']);
                
                if ($mysqli->query("INSERT INTO entries (name, message) VALUES ('$name', '$message')")) {
                    echo '<div class="success">Entry added successfully!</div>';
                }
            }
            ?>
            <h2>Add New Entry</h2>
            <form method="POST">
                <p>Name: <input name="name" required></p>
                <p>Message: <textarea name="message"></textarea></p>
                <button type="submit">Add Entry</button>
            </form>
            <?php
        }
        
        elseif ($page == 'view') {
            echo '<h2>All Entries</h2>';
            $result = $mysqli->query("SELECT * FROM entries ORDER BY created_at DESC");
            
            if ($result->num_rows > 0) {
                echo '<table><tr><th>ID</th><th>Name</th><th>Message</th><th>Date</th></tr>';
                while ($row = $result->fetch_assoc()) {
                    echo '<tr>';
                    echo '<td>' . $row['id'] . '</td>';
                    echo '<td>' . htmlspecialchars($row['name']) . '</td>';
                    echo '<td>' . htmlspecialchars($row['message']) . '</td>';
                    echo '<td>' . $row['created_at'] . '</td>';
                    echo '</tr>';
                }
                echo '</table>';
            } else {
                echo '<p>No entries found.</p>';
            }
        }
        
        elseif ($page == 'info') {
            echo '<h2>System Information</h2>';
            echo '<p><strong>PHP Version:</strong> ' . PHP_VERSION . '</p>';
            echo '<p><strong>Server:</strong> ' . $_SERVER['SERVER_SOFTWARE'] . '</p>';
            
            $info = $mysqli->query("SELECT VERSION() as version")->fetch_assoc();
            echo '<p><strong>MySQL Version:</strong> ' . $info['version'] . '</p>';
            
            $count = $mysqli->query("SELECT COUNT(*) as total FROM entries")->fetch_assoc();
            echo '<p><strong>Total Entries:</strong> ' . $count['total'] . '</p>';
        }
        
        $mysqli->close();
        
    } catch (Exception $e) {
        echo '<div class="error">Error: ' . htmlspecialchars($e->getMessage()) . '</div>';
    }
    ?>
</body>
</html>
EOF

# Create health check
cat > /var/www/html/health.php << 'EOF'
<?php
header('Content-Type: application/json');
try {
    require_once 'db_config.php';
    $mysqli = getDBConnection();
    $mysqli->query("SELECT 1");
    echo '{"status":"healthy","database":"connected"}';
    $mysqli->close();
} catch (Exception $e) {
    http_response_code(503);
    echo '{"status":"error","message":"' . $e->getMessage() . '"}';
}
?>
EOF

# Set permissions
chown -R apache:apache /var/www/html
chmod 644 /var/www/html/*.php

# Configure Apache
cat > /etc/httpd/conf.d/simple.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    <FilesMatch "\.php$">
        SetHandler application/x-httpd-php
    </FilesMatch>
</VirtualHost>
EOF

# Restart Apache
systemctl restart httpd

# Create simple test script
cat > /home/ec2-user/test-app.sh << 'EOF'
#!/bin/bash
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "App URL: http://$PUBLIC_IP/"
echo "Health: http://$PUBLIC_IP/health.php"
curl -s http://localhost/health.php
EOF

chmod +x /home/ec2-user/test-app.sh
chown ec2-user:ec2-user /home/ec2-user/test-app.sh

echo "✅ Simple Apache + RDS setup complete!"