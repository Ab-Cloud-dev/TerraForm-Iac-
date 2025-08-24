# AWS VPC and Subnet Provisioning with Terraform

This project demonstrates the use of **Terraform (Infrastructure as Code)** to create a secure and scalable AWS network foundation.  
It provisions an **Amazon VPC** and **Subnet** using **variables, explicit dependencies, and outputs** for a clean, reusable, and production-ready setup.

---

## **Why This Project?**

Networking is the backbone of any cloud architecture.  
By automating the creation of a **Virtual Private Cloud (VPC)** and **Subnet**, this project:

- Ensures **consistency and repeatability** across environments (Dev, QA, Prod).
- Eliminates manual configuration errors.
- Demonstrates **Infrastructure as Code (IaC)** skills crucial for **Cloud Engineers, DevOps, and Solutions Architects**.
- Serves as a foundation to scale into **multi-tier architectures, EKS clusters, or hybrid cloud solutions**.

---

## **Key Features**

- **VPC Creation** – Configured with a `/16` CIDR for flexibility.  
- **Subnet Creation** – Attached to the VPC with explicit `depends_on` to control resource order.  
- **Parameterization with Variables** – Easy renaming or reuse across multiple environments.  
- **Organized File Structure** – Follows Terraform best practices.  
- **Clean Outputs** – Displays resource names post-provisioning for validation and integration.  

---

## **Repository Structure**

```bash
.
├── main.tf             # Core resources (VPC and Subnet)
├── variables.tf        # Input variables definition
├── terraform.tfvars    # Variable values for environment
├── outputs.tf          # Outputs for verification and integration
└── README.md           # Project documentation

```

## **How It Works**

1. Variables – Names of VPC and Subnet are externalized into terraform.tfvars.

2. Resources – aws_vpc and aws_subnet resources are declared in main.tf.

3. Dependencies – Subnet uses depends_on to ensure the VPC is created first.

4. Outputs – Resource names are displayed after provisioning for validation.



## **Steps to Deploy**

1. Clone the Repository

```
git clone https://github.com/Ab-Cloud-dev/TerraForm-Iac-.git

cd 01-Create-VPC-Subnet-Using-Terraform-Variables

```

2. Update Variable Values

Edit terraform.tfvars to match your desired names:

```
kke_vpc_name   = "datacenter-vpc"

kke_subnet_name = "datacenter-subnet"
```


3. Initialize Terraform

```
terraform init
```
4. Apply the Configuration

```
terraform apply
```
5. Verify Outputs

   <img width="2000" height="407" alt="image" src="https://github.com/user-attachments/assets/d836077e-44c0-4e8e-acc4-3aa47b3cb596" />


## **Sample Outputs**

kke_vpc_name = "datacenter-vpc"

kke_subnet_name = "datacenter-subnet"

## **Benefits of Using Terraform for Networking**

Scalable Infrastructure – Easily extend to multiple subnets, route tables, gateways, etc.

Reusable Modules – Build once, deploy many times with minimal changes.

Version Control – Store IaC in GitHub for collaboration and rollback.

Automation & CI/CD Ready – Integrates with Jenkins, GitHub Actions, or other pipelines.

Clear Documentation – Outputs and tags make resources easy to track and manage.
