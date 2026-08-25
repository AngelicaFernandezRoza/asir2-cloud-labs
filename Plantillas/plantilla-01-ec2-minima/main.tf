# Le dice a Terraform qué plugin (provider) necesita para hablar con AWS
# y en qué versión. Sin esto, Terraform no sabe cómo traducir el código
# a llamadas a la API de AWS.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configura el provider de AWS: región donde se crearán todos los
# recursos de este fichero. us-east-1 es la región de Virginia (EE. UU.).
provider "aws" {
  region = "us-east-1"
}

# Crea la máquina virtual (instancia EC2) que es el objetivo de esta plantilla.
resource "aws_instance" "mi_servidor" {
  # AMI = "plantilla de sistema operativo" con la que arranca la máquina.
  # Este valor es un marcador de posición: hay que sustituirlo por el ID
  # real de una AMI de la región us-east-1 antes de aplicar la plantilla.
  ami = "ami-0b6d9d3d33ba97d99"

  # Tamaño de la máquina (CPU/RAM). t2.micro es el más pequeño y suele
  # estar cubierto por la capa gratuita de AWS.
  instance_type = "t3.micro"

  # Etiquetas para identificar el recurso en la consola de AWS.
  tags = {
    Name = "ec2-minima"
  }
}
