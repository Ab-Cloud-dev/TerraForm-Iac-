<?php
// Database configuration - move to separate config file in production
$config = array(
    'servername' => "database-1.c3s6ucy4qdsc.us-east-1.rds.amazonaws.com",
    'username' => "admin",
    'password' => "EDIPJmMqPYVJfzuBISGK",
    'database' => "intel"
);

$message = '';
$messageType = '';
$firstname = '';
$email = '';

// Process form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Validate and sanitize input
    $firstname = isset($_POST['firstname']) ? trim($_POST['firstname']) : '';
    $email = isset($_POST['email']) ? trim($_POST['email']) : '';
    
    // Validation
    $errors = array();
    
    if (empty($firstname)) {
        $errors[] = "Name is required.";
    } elseif (strlen($firstname) > 100) {
        $errors[] = "Name must be less than 100 characters.";
    }
    
    if (empty($email)) {
        $errors[] = "Email is required.";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Please enter a valid email address.";
    } elseif (strlen($email) > 255) {
        $errors[] = "Email must be less than 255 characters.";
    }
    
    if (empty($errors)) {
        // Create connection
        $conn = new mysqli(
            $config['servername'], 
            $config['username'], 
            $config['password'], 
            $config['database']
        );
        
        // Check connection
        if ($conn->connect_error) {
            error_log("Database connection failed: " . $conn->connect_error);
            $message = "Sorry, there was an error processing your request. Please try again later.";
            $messageType = "danger";
        } else {
            // Set charset to prevent character set confusion attacks
            $conn->set_charset("utf8");
            
            // Use prepared statement to prevent SQL injection
            $stmt = $conn->prepare("INSERT INTO data (firstname, email) VALUES (?, ?)");
            
            if ($stmt) {
                $stmt->bind_param("ss", $firstname, $email);
                
                if ($stmt->execute()) {
                    $message = "Record created successfully!";
                    $messageType = "success";
                    // Clear form data after successful submission
                    $firstname = '';
                    $email = '';
                } else {
                    error_log("Execute failed: " . $stmt->error);
                    $message = "Sorry, there was an error processing your request. Please try again later.";
                    $messageType = "danger";
                }
                
                $stmt->close();
            } else {
                error_log("Prepare statement failed: " . $conn->error);
                $message = "Sorry, there was an error processing your request. Please try again later.";
                $messageType = "danger";
            }
            
            $conn->close();
        }
    } else {
        $message = implode('<br>', $errors);
        $messageType = "danger";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Form</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <style>
        body {
            background-image: url('images/2.png');
            background-repeat: no-repeat;
            background-size: cover;
            background-attachment: fixed;
            min-height: 100vh;
        }
        .form-container {
            margin-top: 5rem;
            background: rgba(255, 255, 255, 0.95);
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .required {
            color: red;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-md-6 col-md-offset-3">
                <div class="form-container">
                    <h2 class="text-center">Contact Form</h2>
                    
                    <?php if (!empty($message)): ?>
                        <div class="alert alert-<?php echo htmlspecialchars($messageType); ?>" role="alert">
                            <?php echo $message; ?>
                        </div>
                    <?php endif; ?>
                    
                    <form method="post" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>">
                        <!-- CSRF token would go here in a real application -->
                        
                        <div class="form-group">
                            <label for="firstname">
                                Name <span class="required">*</span>
                            </label>
                            <input 
                                type="text" 
                                class="form-control" 
                                id="firstname"
                                name="firstname" 
                                value="<?php echo htmlspecialchars($firstname); ?>"
                                maxlength="100"
                                required
                            >
                        </div>
                        
                        <div class="form-group">
                            <label for="email">
                                Email <span class="required">*</span>
                            </label>
                            <input 
                                type="email" 
                                class="form-control" 
                                id="email"
                                name="email" 
                                value="<?php echo htmlspecialchars($email); ?>"
                                maxlength="255"
                                required
                            >
                        </div>
                        
                        <div class="text-center">
                            <button type="submit" class="btn btn-success btn-lg">
                                Submit
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</body>
</html>