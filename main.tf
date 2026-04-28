terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}

# ЦЕЙ БЛОК МАЄ БУТИ ОБОВ'ЯЗКОВО:
resource "aws_security_group" "lab6_sg" {
  name        = "allow_web_ssh_lab6"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.lab6_sg.id]

  # Переконайся, що створив цей ключ у консолі регіону us-east-1
  key_name               = "lab5-key" 

  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              EOF

  tags = {
    Name = "Lab6-Terraform-Server"
  }
}

output "instance_public_ip" {
  description = "Публічна IP-адреса створеного сервера"
  value       = aws_instance.web_server.public_ip
}