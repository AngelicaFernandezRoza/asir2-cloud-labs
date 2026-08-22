# Este fichero declara las "variables de entrada" de la plantilla: huecos
# que el código deja libres para que cada alumno rellene con sus propios
# valores sin tener que tocar main.tf. Los valores reales se escriben en
# terraform.tfvars.

# No tiene "default": es obligatorio indicar un valor en terraform.tfvars,
# si no, Terraform lo pedirá por terminal antes de continuar.
variable "nombre_alumno" {
  description = "Tu nombre. Se usara como etiqueta en los recursos."
  type        = string
}

# Sí tiene "default": si no se indica nada en terraform.tfvars, Terraform
# usará automáticamente "t2.micro".
variable "tipo_instancia" {
  description = "Tipo de instancia EC2."
  type        = string
  default     = "t2.micro"
}

# Sin default y obligatoria: cada alumno debe buscar el ID de una AMI
# válida en su región y ponerlo en terraform.tfvars.
variable "ami_id" {
  description = "ID de la AMI a utilizar (us-east-1)."
  type        = string
}
