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

resource "aws_instance" "mi_servidor" {
  ami           = "ami-XXXXXXXXXX"
  instance_type = "t2.micro"

  tags = {
    Name = "kit-plantilla1"
  }
}
