# Bloque de configuracion de Terraform: aqui se indica que "proveedor"
# (plugin) necesita este proyecto para hablar con AWS.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # de donde se descarga el plugin de AWS
      version = "~> 5.0"        # version del plugin (5.x, cualquier version menor)
    }
  }
}

# Bloque "provider": configura el plugin de AWS.
# region indica en que zona geografica de AWS se van a crear los recursos.
provider "aws" {
  region = "us-east-1" # Norte de Virginia (EE.UU.)
}

# Bloque "resource": aqui se define QUE se va a crear.
# "aws_instance" es el tipo de recurso (una maquina virtual EC2).
# "mi_servidor" es el nombre que le damos nosotros dentro de Terraform
# (solo se usa para referenciarlo en este proyecto, no es el nombre real en AWS).
resource "aws_instance" "mi_servidor" {
  ami           = "ami-XXXXXXXXXX" # Sustituye por una AMI valida en us-east-1
  instance_type = "t2.micro"       # Tipo de maquina: t2.micro = capa gratuita

  # Etiquetas: metadatos para identificar el recurso en la consola de AWS.
  tags = {
    Name = "kit-plantilla1"
  }
}
