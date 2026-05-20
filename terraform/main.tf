# Fetch the default VPC within the region for deployment convenience
data "aws_vpc" "default" {
  default = true
}

# Fetch your local machine's public IP dynamically to restrict ingress rules
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

# -----------------------------------------------------------------
# Security Group: Strict ingress control rules
# -----------------------------------------------------------------
resource "aws_security_group" "automation_server_sg" {
  name        = "devsecops-automation-sg"
  description = "Strict firewall control for automation node"
  vpc_id      = data.aws_vpc.default.id

  # Allow inbound access to the pipeline tools ONLY from your current public IP
  ingress {
    description = "SSH administrative access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    description = "Jenkins/Automation dashboard access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  # Unrestricted outbound traffic allowing the node to download security definitions
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.environment_tag}-sg"
  }
}

# -----------------------------------------------------------------
# IAM Role & Instance Profile (Least Privilege Architecture)
# -----------------------------------------------------------------
resource "aws_iam_role" "ec2_security_role" {
  name = "devsecops-ec2-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# Attach AmazonSSMManagedInstanceCore so we can manage the node securely without exposing SSH keys
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_security_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "devsecops-ec2-profile"
  role = aws_iam_role.ec2_security_role.name
}

# Fetch the latest stable Amazon Linux 2023 AMI identifier
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# -----------------------------------------------------------------
# Compute Resource Instance Deployment
# -----------------------------------------------------------------
resource "aws_instance" "automation_server" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_groups      = [aws_security_group.automation_server_sg.name]

  # Enable encrypted root volume storage blocks
  root_block_device {
    volume_size           = 30 # Provides plenty of room for running container image builds
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # Automated user data engine script to run on initial boot
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y docker git python3-pip
              sudo systemctl enable --now docker
              sudo usermod -aG docker ec2-user
              EOF

  tags = {
    Name = var.environment_tag
  }
}

output "server_public_ip" {
  value       = aws_instance.automation_server.public_ip
  description = "Public IP address allocated to the platform"
}
