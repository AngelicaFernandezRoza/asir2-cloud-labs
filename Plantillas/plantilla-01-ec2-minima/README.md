# Plantilla 01 · EC2 mínima

## 1. ¿Qué hace esta plantilla?

Esta plantilla crea una máquina virtual EC2 y un grupo de seguridad para permitir conexiones SSH. No configura una red personalizada ni utiliza variables o ficheros adicionales: todo el código cabe en `main.tf`.

Piensa en Terraform como una "lista de la compra" que le entregas a AWS: en lugar de entrar en la consola web y pinchar botones para crear la máquina, escribes en un fichero de texto qué quieres tener, y Terraform se encarga de pedírselo a AWS por ti. La ventaja es que ese fichero queda guardado, se puede repetir, compartir y modificar, mientras que los clics en la consola no dejan ningún rastro reutilizable.

El objetivo de esta plantilla es aprender cómo Terraform declara varios recursos y cómo se asocian: además de la instancia EC2, se define el grupo de seguridad que controla el tráfico de red.

## 2. ¿Qué recursos de AWS crea?

Esta plantilla declara dos recursos de AWS:

- **Instancia EC2** (`aws_instance`): es una máquina virtual dentro de AWS, equivalente a un ordenador que se enciende en un centro de datos de Amazon y al que puedes acceder por red igual que harías con cualquier servidor físico. EC2 significa *Elastic Compute Cloud*: "elastic" porque puedes crear o destruir tantas como necesites, y "compute" porque su función es ejecutar procesos, igual que la CPU y la RAM de un PC.
- **Grupo de seguridad** (`aws_security_group`): es un conjunto de reglas de red asociado a recursos como una EC2. En esta plantilla permite el tráfico entrante TCP por el puerto 22 (SSH) desde cualquier dirección IPv4 (`0.0.0.0/0`) y permite todo el tráfico saliente. Al aceptar SSH desde cualquier dirección, esta regla es amplia y solo debería usarse en este ejercicio.

Analizando el código de `main.tf`, bloque a bloque:

```hcl
# Declara el provider de AWS que Terraform necesita para crear recursos en AWS.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

Este bloque no crea nada en AWS: le dice a Terraform **qué plugin necesita** para poder hablar con AWS (llamado *provider*) y qué versión usar. Es como instalar el "controlador" antes de poder usar un periférico: sin este bloque, Terraform no sabría cómo traducir tu código a llamadas a la API de AWS.

```hcl
# Configura la región de AWS donde se crearán los recursos.
provider "aws" {
  region = "us-east-1"
}
```

Aquí configuras el provider que acabas de declarar: le indicas en qué **región** de AWS quieres trabajar. Una región es una zona geográfica con sus propios centros de datos (por ejemplo, `us-east-1` está en Virginia, EE. UU.). Todos los recursos de este fichero se crearán en esa región, salvo que se indique lo contrario.

```hcl
# Crea un grupo de seguridad con reglas de entrada y salida para la instancia.
resource "aws_security_group" "permitir_ssh" {
  name = "permitir-ssh"

  # Permite conexiones SSH entrantes desde cualquier dirección IPv4.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite todo el tráfico saliente desde la instancia.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

El grupo define qué tráfico puede entrar y salir. La regla de entrada abre el puerto estándar de SSH (22) para todo Internet; en un entorno real convendría limitarla a la dirección IP desde la que se administra el servidor.

```hcl
# Crea la máquina virtual EC2 y configura su imagen, tamaño y acceso.
resource "aws_instance" "mi_servidor" {
  ami           = "ami-XXXXXXXXXX"
  instance_type = "t2.micro"

  # Usa una key pair que ya debe existir en la cuenta de AWS.
  key_name = "vockey"

  # Asocia a la instancia el grupo de seguridad creado para SSH.
  security_groups = ["permitir_ssh"]

  # Añade una etiqueta visible en la consola de AWS.
  tags = {
    Name = "kit-plantilla1"
  }
}
```

Este bloque crea y configura la máquina virtual:

- `resource "aws_instance" "mi_servidor"`: declara un recurso de tipo `aws_instance` (una EC2) y le da el nombre interno `mi_servidor`. Ese nombre solo se usa dentro del código Terraform, no aparece en AWS.
- `ami`: la AMI (*Amazon Machine Image*) es la "plantilla de sistema operativo" con la que arranca la máquina, similar a una imagen ISO ya instalada y lista para clonar. El valor `ami-XXXXXXXXXX` es un marcador de posición: **hay que sustituirlo** por el ID real de una AMI de tu región antes de poder crear la instancia (más detalle en el apartado 4).
- `instance_type`: define el "tamaño" del ordenador virtual (CPU, RAM...). `t2.micro` es uno de los tipos más pequeños y económicos, e incluso está incluido en la capa gratuita de AWS.
- `key_name`: indica el nombre de una key pair (*par de claves*) que ya debe existir en AWS. `vockey` suele estar disponible en los entornos de AWS Academy/Vocareum. Para iniciar sesión por SSH también necesitarás la clave privada correspondiente.
- `security_groups`: indica el nombre del grupo de seguridad asociado a la instancia. En este caso coincide con el nombre `permitir-ssh` declarado en el recurso `aws_security_group`.
- `tags`: son etiquetas de tipo clave-valor que se asignan al recurso para identificarlo en la consola de AWS. Aquí se le pone el nombre `kit-plantilla1`, que es el que verás en el listado de instancias EC2.

## 3. Requisitos previos

Para poder usar esta plantilla necesitas:

- **Terraform instalado** en tu equipo. Puedes comprobarlo ejecutando `terraform -version` en una terminal.
- **Una cuenta de AWS** y credenciales de acceso configuradas (Access Key ID y Secret Access Key), normalmente mediante el comando `aws configure` (requiere tener instalado el AWS CLI) o mediante variables de entorno. Terraform usa esas credenciales para autenticarse en tu nombre, igual que usas usuario y contraseña para entrar en la consola web.
- **El ID de una AMI válida** para la región `us-east-1`. El valor `ami-XXXXXXXXXX` que aparece en `main.tf` es ficticio y no funcionará: debes buscar en la consola de AWS (EC2 → Lanzar instancia → catálogo de AMI) el ID de una imagen real, por ejemplo la de Amazon Linux, y sustituirlo en el fichero antes de continuar.
- **Una key pair llamada `vockey`** ya creada en la misma región y cuenta. Si usas AWS Academy/Vocareum, comprueba que el entorno te proporciona esta key pair. Para conectarte por SSH, necesitarás además su clave privada.

## 4. Cómo usarla

Desde una terminal, sitúate en la carpeta de esta plantilla y ejecuta los siguientes comandos en orden:

```bash
terraform init
```
Prepara la carpeta de trabajo: descarga el provider de AWS declarado en `required_providers` y crea una carpeta oculta `.terraform` con los archivos necesarios. Solo hace falta ejecutarlo la primera vez (o si cambias de provider).

```bash
terraform plan
```
Calcula y muestra en pantalla **qué va a hacer** Terraform si aplicas el código, pero sin hacer ningún cambio real todavía. Revisa que el plan incluya el grupo de seguridad y la instancia EC2.

```bash
terraform apply
```
Ejecuta de verdad los cambios: crea el grupo de seguridad y la instancia EC2 en tu cuenta de AWS. Terraform te volverá a mostrar el plan y te pedirá que confirmes escribiendo `yes`.

> Antes de ejecutar `terraform apply`, sustituye `ami-XXXXXXXXXX` por un ID de AMI real y asegúrate de que existe la key pair `vockey`.

## 5. Qué ocurre cuando se ejecuta

Al terminar `terraform apply` con éxito, en la consola de AWS (región Norte de Virginia) verás un nuevo grupo de seguridad en **EC2 → Grupos de seguridad** y una instancia en **EC2 → Instancias**:

- Con el nombre `kit-plantilla1` (la etiqueta que le pusimos en `tags`).
- De tipo `t2.micro`.
- En estado *running* (en ejecución) a los pocos segundos o minutos.
- Con una IP pública asignada automáticamente. La regla del grupo de seguridad permite intentar una conexión SSH desde cualquier dirección, y la key pair `vockey` configura la clave pública de acceso. Para iniciar sesión necesitarás la clave privada correspondiente y el usuario adecuado para la AMI.

Terraform, además, guarda en la misma carpeta un fichero `terraform.tfstate`. Este archivo es el "mapa" que usa Terraform para recordar qué ha creado y así saber qué modificar o borrar en el futuro. **No lo borres ni lo edites a mano.**

## 6. Cómo destruir los recursos creados

La instancia EC2 en ejecución puede generar costes (la cobertura de la capa gratuita depende de la cuenta y sus condiciones vigentes). Para evitar cargos innecesarios, destruye los recursos en cuanto termines el ejercicio:

```bash
terraform destroy
```

Terraform te mostrará qué recursos va a eliminar y pedirá confirmación con `yes`. Tras confirmar, borrará la instancia EC2 y el grupo de seguridad. La instancia pasará a estado *terminated* y desaparecerá de la lista al cabo de un rato.
