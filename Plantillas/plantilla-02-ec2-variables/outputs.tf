# Los "outputs" son datos que Terraform imprime en pantalla al terminar
# terraform apply (y que puedes volver a consultar con terraform output).
# Sirven para no tener que ir a la consola de AWS a buscar a mano datos
# de un recurso que ya has creado.

# IP pública de la instancia: la usarás para conectarte por SSH o HTTP.
output "ip_publica" {
  description = "IP publica de la instancia creada EC2."
  value       = aws_instance.servidor.public_ip
}

# Identificador único de la instancia dentro de AWS.
output "id_instancia" {
  description = "ID de la instancia EC2."
  value       = aws_instance.servidor.id
}

# Nombre DNS público asociado a la instancia, alternativa a usar la IP.
output "dns_publico" {
  description = "DNS publico de la instancia."
  value       = aws_instance.servidor.public_dns
}
