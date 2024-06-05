# Specify the AWS provider and region
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

resource "aws_security_group" "instance_sg" {
  name        = "ec2-instance-sg"
  description = "Security group for EC2 instance"

  # Ingress rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing SSH access from anywhere
  }

  # Egress rule (outbound)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # All destinations
  }
}
resource "aws_instance" "example" {
  ami             = "ami-04b70fa74e45c3917" # Replace with your desired Ubuntu AMI
  instance_type   = "t2.micro"
  key_name        = "vpc-1-ec2-key"                       # Replace with your key pair name
  security_groups = [aws_security_group.instance_sg.name] # Associate the instance with the new security group

  tags = {
    Name = "ec2-docker-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",                                       # Update package index
      "sudo apt-get install -y docker.io",                            # Install Docker
      "sudo systemctl start docker",                                  # Start Docker service
      "sudo usermod -aG docker ubuntu",                               # Add ubuntu user to the docker group
      "git clone https://github.com/akshayviola/node-app-docker.git", # Clone your Git repository
      # Additional commands if needed...
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"                                       # Replace with your SSH username for Ubuntu
      private_key = file("/home/user/Downloads/vpc-1-ec2-key.pem") # Path to your private key file
      host        = self.public_ip
    }
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

output "private_ip" {
  value = aws_instance.example.private_ip
}

output "instance_state" {
  value = aws_instance.example.instance_state
}

output "availability_zone" {
  value = aws_instance.example.availability_zone
}
