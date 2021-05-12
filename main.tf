terraform {
  required_providers {
    aws = {}
  }
}
# Nesse bloco, estamos definindo o provider. O provider é um plugin que nos abilita interagir com sistemas remotos. Os providers podem ser encontrados aqui: https://registry.terraform.io/browse/providers
provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "provisioner_remote" {
  ami           = "ami-0a313d6098716f372"
  instance_type = "t2.micro"
  security_groups = [ 
    aws_security_group.allow_http.name
    ]
  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo systemctl enable httpd.service",
      "sudo systemctl start httpd.service"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }  
  tags = {
    "Name" = "Remote-exec"
  }
  provisioner "file" {
    source      = "/home/rodrigo/meuprimeirorepositorio/check_point2/index.html"
    destination = "/home/var/www/html/index.html"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
      host        = self.public_ip
    }
  }
}
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound"
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
