variable "nombre_alumno" {
  description = "Tu nombre. Se usara como etiqueta en los recursos."
  type        = string
}

variable "tipo_instancia" {
  description = "Tipo de instancia EC2."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "ID de la AMI a utilizar (us-east-1)."
  type        = string
}
