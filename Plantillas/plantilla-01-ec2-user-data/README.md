# Plantilla 01 · EC2 con user-data

## 1. ¿Qué hace esta plantilla?

Esta plantilla crea una máquina virtual EC2 en AWS, permite conectarse a ella por SSH y ejecuta un script al arrancar por primera vez para instalar Nginx.

Piensa en `user_data` como las instrucciones de preparación que acompañan a una máquina nueva: AWS las entrega a la instancia durante su primer arranque y el sistema operativo las ejecuta automáticamente. Así, además de crear la máquina, Terraform puede dejar instalado un programa sin que tengas que conectarte primero para hacerlo a mano.

Todo el código está en `main.tf`. La AMI debe ser de Ubuntu o Debian, porque el script instala paquetes con `apt-get`.

## 2. ¿Qué recursos de AWS crea?

Esta plantilla declara dos recursos de AWS:

- **Grupo de seguridad** (`aws_security_group`): es un conjunto de reglas que controla qué tráfico de red puede entrar y salir de la instancia. Aquí permite conexiones SSH por el puerto 22 desde cualquier dirección IPv4 (`0.0.0.0/0`) y permite todo el tráfico saliente. Abrir SSH a todo Internet es una regla amplia, adecuada solo para este ejercicio; en un entorno real convendría limitarla a la IP desde la que te conectas.
- **Instancia EC2** (`aws_instance`): es una máquina virtual que ejecuta un sistema operativo y programas. En esta plantilla usa el tipo `t2.micro`, la key pair `vockey` y el grupo de seguridad anterior. Su `user_data` instala Nginx durante el primer arranque.

Analizando las partes principales de `main.tf`:

```hcl
# Declara el plugin de AWS que Terraform necesita para administrar recursos de AWS.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

Este bloque no crea recursos en AWS. Indica a Terraform qué *provider* necesita: el plugin que traduce los bloques Terraform a llamadas a la API de AWS.

```hcl
# Configura la región donde se crearán los recursos de esta plantilla.
provider "aws" {
  region = "us-east-1"
}
```

La región es la zona geográfica de AWS en la que se crearán los recursos. `us-east-1` corresponde a Norte de Virginia, Estados Unidos.

```hcl
# Crea las reglas de red asociadas a la instancia EC2.
resource "aws_security_group" "permitir_ssh" {
  name = "permitir-ssh"

  # Permite conexiones SSH entrantes desde cualquier dirección IPv4.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite todo el tráfico saliente iniciado por la instancia.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

`ingress` describe el tráfico que entra: en este caso, conexiones TCP por el puerto 22, el puerto habitual de SSH. `egress` describe el tráfico que sale; el protocolo `-1` representa todos los protocolos.

```hcl
# Crea la instancia EC2 y configura el script que se ejecuta en su primer arranque.
resource "aws_instance" "mi_servidor" {
  ami           = "ami-XXXXXXXXXX"
  instance_type = "t2.micro"

  # Usa una key pair que ya debe existir en la cuenta y la región de AWS.
  key_name = "vockey"

  # Asocia a la EC2 el grupo de seguridad declarado arriba.
  vpc_security_group_ids = [aws_security_group.permitir_ssh.id]

  # Ejecuta este script al primer arranque para instalar Nginx en Ubuntu o Debian.
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  EOF

  # Añade una etiqueta visible en la consola de AWS.
  tags = {
    Name = "kit-plantilla1"
  }
}
```

`vpc_security_group_ids` conecta los dos recursos usando el identificador del grupo de seguridad. `user_data` contiene un script de Linux: actualiza la lista de paquetes e instala Nginx. El marcador `ami-XXXXXXXXXX` debe reemplazarse por el ID de una AMI real de Ubuntu o Debian en `us-east-1`; una AMI de Amazon Linux no es compatible con estos comandos `apt-get`.

## 3. Requisitos previos

Para usar esta plantilla necesitas:

- **Terraform instalado**. Comprueba la instalación con `terraform -version`.
- **Una cuenta de AWS y credenciales configuradas** para que Terraform pueda autenticarse, por ejemplo mediante `aws configure` si tienes instalado AWS CLI, o mediante variables de entorno.
- **El ID de una AMI de Ubuntu o Debian** válida en la región `us-east-1`. El valor `ami-XXXXXXXXXX` de `main.tf` es un marcador de posición y no funcionará hasta que lo sustituyas.
- **Una key pair llamada `vockey`** creada en la misma cuenta y región. Suele estar disponible en AWS Academy/Vocareum. Para conectarte por SSH necesitarás también la clave privada correspondiente.

## 4. Cómo usarla

Abre una terminal en la carpeta de esta plantilla y ejecuta los comandos en orden:

```bash
terraform init
```

Descarga el provider de AWS y prepara el directorio de trabajo de Terraform. Normalmente se ejecuta la primera vez o cuando cambia la configuración del provider.

```bash
terraform plan
```

Muestra los cambios que Terraform propone, sin crear todavía recursos. Comprueba que el plan incluya un grupo de seguridad y una instancia EC2.

```bash
terraform apply
```

Aplica el plan y crea los recursos en AWS. Terraform pedirá confirmación; escribe `yes` para continuar.

> Antes de aplicar, sustituye `ami-XXXXXXXXXX` en `main.tf` por una AMI de Ubuntu o Debian de `us-east-1` y confirma que existe la key pair `vockey`.

## 5. Qué ocurre cuando se ejecuta

Cuando la operación termina correctamente, en la región Norte de Virginia verás el grupo de seguridad en **EC2 → Grupos de seguridad** y la máquina en **EC2 → Instancias**. La instancia tendrá la etiqueta `kit-plantilla1` y será de tipo `t2.micro`.

Durante el primer arranque, AWS ejecutará el script de `user_data`: actualizará la lista de paquetes e instalará Nginx. La instalación puede tardar unos minutos. El script se ejecuta al inicializar la instancia, no cada vez que la reinicias.

El grupo de seguridad solo permite conexiones entrantes por SSH (puerto 22). Aunque Nginx quede instalado, esta plantilla no abre el puerto HTTP (80), así que no podrás acceder a su página web desde Internet. Para conectarte por SSH necesitarás una dirección IP pública alcanzable, la clave privada de `vockey` y el usuario de inicio de sesión que corresponda a la AMI.

Terraform también guardará el estado de los recursos en `terraform.tfstate`. Ese archivo permite a Terraform recordar qué recursos administra; no lo borres ni lo edites a mano.

## 6. Cómo destruir los recursos creados

Una instancia EC2 puede generar costes mientras está activa. Cuando termines el ejercicio, elimina tanto la instancia como el grupo de seguridad:

```bash
terraform destroy
```

Terraform mostrará qué va a borrar y pedirá confirmación con `yes`. Al confirmar, eliminará la instancia EC2 y, después, el grupo de seguridad asociado.
