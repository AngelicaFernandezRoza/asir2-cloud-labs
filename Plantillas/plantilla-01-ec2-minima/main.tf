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

# Primer bloque "resource": En los bloques de tipo resource se define QUÉ se va a crear. 
# En este caso un Security Group (grupo de seguridad) que se asociará posteriormente a la 
# instancia EC2 para permitir el acceso por SSH a través del puerto 22.

resource "aws_security_group" "permitir_ssh" {
  name = "permitir-ssh"

  # Permite tráfico ENTRANTE por puerto 22 (SSH)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite tráfico SALIENTE (todo)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Segundo bloque "resource": aqui se define QUÉ se va a crear.
# "aws_instance" es el tipo de recurso (una maquina virtual EC2).
# "mi_servidor" es el nombre que le damos nosotros dentro de Terraform
# (solo se usa para referenciarlo en este proyecto, no es el nombre real en AWS).
resource "aws_instance" "mi_servidor" {
  ami           = "ami-XXXXXXXXXX" # Sustituye por una AMI valida en us-east-1
  instance_type = "t2.micro"       # Tipo de maquina: t2.micro = capa gratuita

  # Nombre de la key pair ya existente en la cuenta de AWS Academy (Vocareum). 
  key_name = "vockey"

  # Asociar el security group a la instancia
  security_groups = ["permitir-ssh"]

  # Etiquetas: metadatos para identificar el recurso en la consola de AWS.

  tags = {
    Name = "kit-plantilla1"
  }
}
