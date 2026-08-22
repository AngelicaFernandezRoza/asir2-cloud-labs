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

# Crea la máquina virtual (instancia EC2). A diferencia de la plantilla 01,
# aquí ningún valor va escrito a fuego en el código: todos vienen de
# variables (var.xxx), cuyo valor real se define en terraform.tfvars.
resource "aws_instance" "servidor" {
  # AMI = "plantilla de sistema operativo" con la que arranca la máquina.
  ami = var.ami_id

  # Tamaño de la máquina (CPU/RAM).
  instance_type = var.tipo_instancia

  # Etiquetas para identificar el recurso en la consola de AWS.
  # "${var.nombre_alumno}" inserta el valor de la variable dentro del
  # texto: es lo que en Terraform se llama interpolación de cadenas.
  tags = {
    Name    = "kit-${var.nombre_alumno}"
    Owner   = var.nombre_alumno
    Project = "kit-supervivencia"
  }
}
