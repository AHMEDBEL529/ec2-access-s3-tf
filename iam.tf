# Retrieve the default VPC dynamically
data "aws_vpc" "default" {
  default = true
}

# Output the VPC ID (optional, for verification)
output "vpc_id" {
  value = data.aws_vpc.default.id
}

# Create IAM Role for EC2 to assume
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = file("assumerolepolicy.json") # Policy allowing EC2 to assume the role
}

# Create IAM Policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "test-policy"
  description = "A test policy that allows access to S3"
  policy      = file("policys3bucket.json") # S3 access policy file
}

# Attach the policy to the role
resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = [aws_iam_role.ec2_s3_access_role.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Generate a random string for the bucket name
resource "random_string" "bucket_suffix" {
  length  = 8     # Length of the random string
  upper   = false # Include uppercase letters (set to true if needed)
  numeric = true  # Use numeric characters
  special = false # Exclude special characters
}

# Create an S3 bucket with a random suffix
resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket-for-ec2-access-${random_string.bucket_suffix.result}"
}



# Create a security group for EC2 and associate it with the dynamically retrieved VPC ID
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id # Dynamically retrieved VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}

# Create a Key Pair for SSH Access
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ec2-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save the private key locally (this will be your .pem file)
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/ec2-key.pem"
}

# Create an EC2 instance and associate the IAM role and security group
resource "aws_instance" "ec2_instance" {
  ami                         = "ami-09d3b3274b6c5d4aa" # Replace with the desired AMI ID
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key_pair.key_name # Add the key pair
  security_groups             = [aws_security_group.ec2_security_group.name]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "EC2-Test-Instance"
  }
}

# Create IAM instance profile to associate the role with EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_s3_access_role.name
}