# Plantilla 02 · EC2 con variables

## 1. ¿Qué hace esta plantilla?

Esta plantilla crea, igual que la [plantilla 01](../plantilla-01-ec2-minima/README.md), **una única máquina virtual en AWS**. La diferencia es que aquí el código ya no tiene ningún valor "escrito a fuego": en vez de poner el nombre, el tipo de instancia o la AMI directamente dentro de `main.tf`, esos datos se sacan a variables que cada alumno rellena en un fichero aparte.

La idea es la misma que usar una plantilla de documento con campos rellenables en lugar de escribir un documento nuevo cada vez desde cero: el "molde" (`main.tf`) es el mismo para toda la clase, y lo único que cambia de un alumno a otro es un pequeño fichero de datos (`terraform.tfvars`). Así se practica uno de los conceptos más importantes de Terraform: separar la **lógica** (qué recursos se crean y cómo) de la **configuración** (con qué valores concretos).

Esta plantilla usa tres ficheros además de `main.tf`:

- `variables.tf`: declara qué variables existen, de qué tipo son y si tienen un valor por defecto.
- `terraform.tfvars`: asigna el valor real de cada variable. **Es el único fichero que debes editar** para adaptar la plantilla a tus datos.
- `outputs.tf`: define qué información se muestra en pantalla al terminar de crear los recursos.

## 2. ¿Qué recursos de AWS crea?

Igual que la plantilla 01, crea un único recurso:

- **Instancia EC2** (`aws_instance`): una máquina virtual dentro de AWS. EC2 significa *Elastic Compute Cloud*: "elastic" porque puedes crear o destruir tantas como necesites, y "compute" porque su función es ejecutar procesos, igual que la CPU y la RAM de un PC.

Veamos el código de cada fichero.

### `main.tf`

```hcl
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
```

Estos dos bloques son idénticos a los de la plantilla 01: le dicen a Terraform qué plugin necesita para hablar con AWS y en qué región va a trabajar (Virginia, EE. UU.).

```hcl
resource "aws_instance" "servidor" {
  ami           = var.ami_id
  instance_type = var.tipo_instancia

  tags = {
    Name    = "kit-${var.nombre_alumno}"
    Owner   = var.nombre_alumno
    Project = "kit-supervivencia"
  }
}
```

Aquí está la diferencia clave con la plantilla 01: en vez de escribir directamente `"ami-XXXXXXXXXX"` o `"t2.micro"`, se usa `var.ami_id` y `var.tipo_instancia`. La palabra `var.` seguida del nombre de la variable le dice a Terraform "coge el valor que se ha definido para esta variable". Es exactamente lo mismo que cuando en programación usas un parámetro en vez de escribir un valor fijo.

En `tags` aparece además `"kit-${var.nombre_alumno}"`. Esto se llama **interpolación de cadenas**: el `${...}` inserta el valor de la variable dentro de un texto, de forma que si `nombre_alumno` vale `"ana"`, la etiqueta `Name` acabará valiendo `"kit-ana"`.

### `variables.tf`

```hcl
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
```

Cada bloque `variable` es como la ficha de un campo de formulario: le da un nombre, una descripción (para saber qué hay que poner) y un tipo de dato (`string` = texto). Fíjate en que `tipo_instancia` tiene un `default`: si no le das ningún valor en `terraform.tfvars`, Terraform usará `"t2.micro"` automáticamente. `nombre_alumno` y `ami_id` no tienen `default`, así que son obligatorias: si no las rellenas, Terraform se detendrá y te las pedirá por terminal.

### `terraform.tfvars`

```hcl
nombre_alumno  = "tu-nombre"
tipo_instancia = "t2.micro"
ami_id         = "ami-XXXXXXXXXX"
```

Este fichero asigna el valor real a cada variable declarada en `variables.tf`. Terraform reconoce automáticamente los ficheros llamados `terraform.tfvars` y los aplica sin que haga falta indicarlo con ningún parámetro extra. Es el único fichero que debes tocar para personalizar la plantilla: **no edites `main.tf` ni `variables.tf`**.

### `outputs.tf`

```hcl
output "ip_publica" {
  description = "IP publica de la instancia creada EC2."
  value       = aws_instance.servidor.public_ip
}

output "id_instancia" {
  description = "ID de la instancia EC2."
  value       = aws_instance.servidor.id
}

output "dns_publico" {
  description = "DNS publico de la instancia."
  value       = aws_instance.servidor.public_dns
}
```

Los `output` no crean nada en AWS: son datos que Terraform imprime en pantalla al terminar `terraform apply`, para que no tengas que ir a la consola web a buscarlos a mano. Aquí se muestran la IP pública, el ID interno y el nombre DNS público de la instancia creada.

## 3. Requisitos previos

- **Terraform instalado** en tu equipo. Puedes comprobarlo con `terraform -version`.
- **Una cuenta de AWS** con credenciales configuradas (por ejemplo, con `aws configure` usando el AWS CLI), para que Terraform pueda autenticarse en tu nombre.
- **El ID de una AMI válida** para la región `us-east-1`. Búscalo en la consola de AWS (EC2 → Lanzar instancia → catálogo de AMI).
- **Haber rellenado `terraform.tfvars`** con tu nombre y con el ID de AMI real, tal y como se explica en el siguiente apartado.

## 4. Cómo usarla

1. Abre el fichero `terraform.tfvars` y sustituye los valores de ejemplo por los tuyos:

   ```hcl
   nombre_alumno  = "ana"
   tipo_instancia = "t2.micro"
   ami_id         = "ami-0abc1234567890def"   # tu AMI real
   ```

2. Desde una terminal, sitúate en la carpeta de esta plantilla y ejecuta, en orden:

```bash
terraform init
```
Descarga el provider de AWS y prepara la carpeta de trabajo. Solo hace falta la primera vez.

```bash
terraform plan
```
Muestra qué va a crear Terraform, ya con los valores de tu `terraform.tfvars` sustituidos en las variables, pero sin aplicar todavía ningún cambio real.

```bash
terraform apply
```
Crea la instancia EC2 en tu cuenta de AWS. Terraform pedirá confirmación escribiendo `yes`. Al terminar, imprimirá en pantalla los tres `outputs` (`ip_publica`, `id_instancia`, `dns_publico`).

## 5. Qué ocurre cuando se ejecuta

Al terminar `terraform apply` con éxito:

- En la consola de AWS (**EC2 → Instancias**, región Norte de Virginia) aparecerá una nueva instancia con el nombre `kit-<tu-nombre>` y las etiquetas `Owner` y `Project`.
- En la terminal verás impresos los valores de `ip_publica`, `id_instancia` y `dns_publico`, listos para copiar y usar (por ejemplo, para conectarte por SSH a la IP pública).
- Si en algún momento quieres volver a consultar esos datos sin repetir el `apply`, puedes ejecutar `terraform output`.
- Terraform guarda en la carpeta un fichero `terraform.tfstate` con el "mapa" de lo que ha creado. **No lo borres ni lo edites a mano.**

## 6. Cómo destruir los recursos creados

Para evitar que la instancia siga generando (posibles) costes, destrúyela en cuanto termines el ejercicio:

```bash
terraform destroy
```

Terraform mostrará qué recursos va a eliminar y pedirá confirmación con `yes`. Tras confirmar, la instancia pasará a estado *terminated* en la consola de AWS y desaparecerá de la lista al cabo de un rato.
