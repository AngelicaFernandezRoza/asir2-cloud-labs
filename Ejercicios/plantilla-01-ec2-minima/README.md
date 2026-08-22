# plantilla-01-ec2-minima

Plantilla Terraform mínima para desplegar una instancia EC2 en AWS. Pensada como primer contacto: todo está en un único fichero (`main.tf`), sin variables ni outputs.

## Qué crea

- 1 instancia EC2 (`aws_instance.mi_servidor`), tipo `t2.micro`, en la región `us-east-1`.
- Etiqueta `Name = kit-plantilla1`.

## Requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) instalado.
- Credenciales de AWS configuradas (`aws configure` o variables de entorno `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`).
- Una AMI válida para `us-east-1` (por ejemplo, la última de Amazon Linux 2023).

## Antes de desplegar

Edita `main.tf` y sustituye el valor de `ami` por el ID real de la AMI que vayas a usar:

```hcl
ami = "ami-XXXXXXXXXX"
```

Puedes consultar el ID actualizado de Amazon Linux 2023 desde la consola de AWS (EC2 > AMIs) o con:

```bash
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
  --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text
```

## Uso

```bash
terraform init
terraform plan
terraform apply
```

## Limpieza

Para no dejar recursos facturando, destruye la instancia al terminar:

```bash
terraform destroy
```

## Siguiente paso

Si necesitas parametrizar el tipo de instancia, la AMI o el nombre, consulta `plantilla-02-ec2-variables`, que añade variables y outputs.
