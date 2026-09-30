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

# Crea un grupo de seguridad para controlar el tráfico de red de la instancia.
resource "aws_security_group" "permitir_ssh" {
  name = "permitir-ssh"

  # Permite conexiones SSH entrantes por el puerto 22 desde cualquier IPv4.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite conexiones HTTP entrantes por el puerto 80.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite que la instancia inicie conexiones salientes.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bloque "resource": aqui se define QUE se va a crear.
# "aws_instance" es el tipo de recurso (una maquina virtual EC2).
# "mi_servidor" es el nombre que le damos nosotros dentro de Terraform
# (solo se usa para referenciarlo en este proyecto, no es el nombre real en AWS).
resource "aws_instance" "mi_servidor" {
  ami           = "ami-0b6d9d3d33ba97d99" # Sustituye por una AMI valida en us-east-1
  instance_type = "t3.micro"       # Tipo de maquina: t2.micro = capa gratuita

  # Nombre de la key pair ya existente en la cuenta de AWS Academy (Vocareum). 
  key_name = "vockey"

  # Asocia a la instancia el grupo de seguridad que permite el acceso SSH.
  vpc_security_group_ids = [aws_security_group.permitir_ssh.id]

  # Ejecuta este script al iniciar la instancia por primera vez; instala Nginx.
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  EOF

  # Etiquetas: metadatos para identificar el recurso en la consola de AWS.

  tags = {
    Name = "kit-plantilla1"
  }
}
