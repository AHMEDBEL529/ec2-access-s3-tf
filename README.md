# ec2-access-s3-tf


# EC2 and S3 Access Setup

## Overview
This project sets up an Amazon EC2 instance with an associated IAM role that allows access to an S3 bucket. The infrastructure is managed using Terraform, which simplifies the process of provisioning and managing cloud resources.

## Technologies Used
- Terraform
- AWS (EC2, S3, IAM)

## Directory Structure
- `iam.tf`: Contains the IAM role and policy definitions.
- `assumerolepolicy.json`: Policy allowing EC2 instances to assume the IAM role.
- `policys3bucket.json`: Policy granting access to the S3 bucket.

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Initialize Terraform**
   Run the following command to initialize the Terraform configuration:
   ```bash
   terraform init
   ```

3. **Plan the Infrastructure**
   Generate and review the execution plan:
   ```bash
   terraform plan
   ```

4. **Apply the Configuration**
   Create the resources in AWS:
   ```bash
   terraform apply
   ```

## Testing the EC2 Instance

### SSH Access

After the EC2 instance is created, you can connect to it using SSH. Follow these steps:

1. **Ensure the `.pem` File is Secured**
   Make sure the `.pem` file has the correct permissions:
   ```bash
   chmod 400 ec2-key.pem
   ```

2. **Connect to the EC2 Instance**
   Use the following command to connect via SSH (replace `<ec2-public-dns>` with the public DNS or IP address of your EC2 instance):
   ```bash
   ssh -i ec2-key.pem ec2-user@<ec2-public-dns>
   ```

3. **Verify Access to the S3 Bucket**
   Once connected, you can test access to the S3 bucket. For example, you can list the contents of the bucket (replace `<bucket-name>` with the name of your S3 bucket):
   ```bash
   aws s3 ls s3://<bucket-name>
   ```

## Conclusion
This setup provides a secure environment for accessing AWS services. The IAM role associated with the EC2 instance ensures that only the necessary permissions are granted, adhering to the principle of least privilege.

## Notes
- Ensure that your AWS credentials are configured properly in your environment for the AWS CLI commands to work.
- Be mindful of AWS resource usage to avoid unexpected charges.
