# DEFINIÇÃO DO PROVIDER
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
# DEFINIÇÃO DA REGIÃO 
provider "aws" {
  region     = "us-east-1"
}
# SECURITY GROUP PARA INSTANCIA
resource "aws_security_group" "Work_VPC" {
  name = "Work_VPC"
  description = "Permite ssh"
  vpc_id = "vpc-0b67c125b8e926673"
# A regra a seguir libera saída para qualquer destino em qualquer protocolo
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]
  }
}
# provisioner
resource "aws_instance" "checkpoint2" {
    ami = "ami-0d5eff06f840b45e9"
    instance_type = "t2.micro"
    subnet_id = "subnet-0bf7eeb4e35c4959d"
    key_name = "nightly"
        provisioner "remote-exec" {
        inline = [ 
            "sudo apt-get update",
            "sudo apt-get -y install nginx",
            "sudo systemctl start nginx"
        ]
    #provisioner "file" {aws_security_group"}
    #   source = "index.html"
    #   destination = "/tmp/index.html"
        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file("~/.ssh/id_rsa")
            host = self.public_ip
        }
      
    }
   provisioner "file" {
   source      = "/home/rodrigo/meuprimeirorepositorio/check_point2/index.html"
   destination = "/tmp/index.html"
   connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file("~/.ssh/id_rsa")                                                                                                                                                                                                                                                                                                                                                                                                                                                     
            host = self.public_ip
    }
    }  
    provisioner "remote-exec" {
        inline = [ 
            "sudo mv /tmp/index.html /var/www/html/index.nginx-debian.html"
        ]
    connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file("~/.ssh/id_rsa")
            host = self.public_ip
  }
}
}