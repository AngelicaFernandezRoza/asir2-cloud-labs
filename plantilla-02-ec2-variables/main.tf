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

resource "aws_instance" "servidor" {
  ami           = var.ami_id
  instance_type = var.tipo_instancia

  tags = {
    Name    = "kit-${var.nombre_alumno}"
    Owner   = var.nombre_alumno
    Project = "kit-supervivencia"
  }
}
