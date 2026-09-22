# Plantilla 01 · EC2 mínima

## 1. ¿Qué hace esta plantilla?

Esta plantilla es el ejercicio más sencillo posible con Terraform: crea **una única máquina virtual en AWS**, sin redes personalizadas, sin variables ni ficheros adicionales. Todo el código cabe en un solo archivo, `main.tf`.

Piensa en Terraform como una "lista de la compra" que le entregas a AWS: en lugar de entrar en la consola web y pinchar botones para crear la máquina, escribes en un fichero de texto qué quieres tener, y Terraform se encarga de pedírselo a AWS por ti. La ventaja es que ese fichero queda guardado, se puede repetir, compartir y modificar, mientras que los clics en la consola no dejan ningún rastro reutilizable.

El objetivo de esta plantilla no es que sea útil en un caso real, sino que sirva para entender la estructura mínima que necesita cualquier proyecto Terraform: decirle **qué proveedor** vas a usar (AWS) y **qué recurso** quieres crear (una instancia EC2).

## 2. ¿Qué recursos de AWS crea?

Esta plantilla crea un único recurso:

- **Instancia EC2** (`aws_instance`): es una máquina virtual dentro de AWS, equivalente a un ordenador que se enciende en un centro de datos de Amazon y al que puedes acceder por red igual que harías con cualquier servidor físico. EC2 significa *Elastic Compute Cloud*: "elastic" porque puedes crear o destruir tantas como necesites, y "compute" porque su función es ejecutar procesos, igual que la CPU y la RAM de un PC.

Analizando el código de `main.tf`, bloque a bloque:

```hcl
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
provider "aws" {
  region = "us-east-1"
}
```

Aquí configuras el provider que acabas de declarar: le indicas en qué **región** de AWS quieres trabajar. Una región es una zona geográfica con sus propios centros de datos (por ejemplo, `us-east-1` está en Virginia, EE. UU.). Todos los recursos de este fichero se crearán en esa región, salvo que se indique lo contrario.

```hcl
resource "aws_instance" "mi_servidor" {
  ami           = "ami-XXXXXXXXXX"
  instance_type = "t2.micro"

  tags = {
    Name = "kit-plantilla1"
  }
}
```

Este es el bloque que realmente crea la máquina virtual:

- `resource "aws_instance" "mi_servidor"`: declara un recurso de tipo `aws_instance` (una EC2) y le da el nombre interno `mi_servidor`. Ese nombre solo se usa dentro del código Terraform, no aparece en AWS.
- `ami`: la AMI (*Amazon Machine Image*) es la "plantilla de sistema operativo" con la que arranca la máquina, similar a una imagen ISO ya instalada y lista para clonar. El valor `ami-XXXXXXXXXX` es un marcador de posición: **hay que sustituirlo** por el ID real de una AMI de tu región antes de poder crear la instancia (más detalle en el apartado 4).
- `instance_type`: define el "tamaño" del ordenador virtual (CPU, RAM...). `t2.micro` es uno de los tipos más pequeños y económicos, e incluso está incluido en la capa gratuita de AWS.
- `tags`: son etiquetas de tipo clave-valor que se asignan al recurso para identificarlo en la consola de AWS. Aquí se le pone el nombre `kit-plantilla1`, que es el que verás en el listado de instancias EC2.

## 3. Requisitos previos

Para poder usar esta plantilla necesitas:

- **Terraform instalado** en tu equipo. Puedes comprobarlo ejecutando `terraform -version` en una terminal.
- **Una cuenta de AWS** y credenciales de acceso configuradas (Access Key ID y Secret Access Key), normalmente mediante el comando `aws configure` (requiere tener instalado el AWS CLI) o mediante variables de entorno. Terraform usa esas credenciales para autenticarse en tu nombre, igual que usas usuario y contraseña para entrar en la consola web.
- **El ID de una AMI válida** para la región `us-east-1`. El valor `ami-XXXXXXXXXX` que aparece en `main.tf` es ficticio y no funcionará: debes buscar en la consola de AWS (EC2 → Lanzar instancia → catálogo de AMI) el ID de una imagen real, por ejemplo la de Amazon Linux, y sustituirlo en el fichero antes de continuar.

## 4. Cómo usarla

Desde una terminal, sitúate en la carpeta de esta plantilla y ejecuta los siguientes comandos en orden:

```bash
terraform init
```
Prepara la carpeta de trabajo: descarga el provider de AWS declarado en `required_providers` y crea una carpeta oculta `.terraform` con los archivos necesarios. Solo hace falta ejecutarlo la primera vez (o si cambias de provider).

```bash
terraform plan
```
Calcula y muestra en pantalla **qué va a hacer** Terraform si aplicas el código, pero sin hacer ningún cambio real todavía. Es una simulación que te permite revisar que va a crear exactamente una instancia EC2 antes de gastar ningún recurso.

```bash
terraform apply
```
Ejecuta de verdad los cambios: crea la instancia EC2 en tu cuenta de AWS. Terraform te volverá a mostrar el plan y te pedirá que confirmes escribiendo `yes`.

> Recuerda sustituir `ami-XXXXXXXXXX` por un ID de AMI real en `main.tf` antes de ejecutar `terraform apply`, o AWS rechazará la petición.

## 5. Qué ocurre cuando se ejecuta

Al terminar `terraform apply` con éxito, en la consola de AWS (sección **EC2 → Instancias**, región Norte de Virginia) verás una nueva instancia:

- Con el nombre `kit-plantilla1` (la etiqueta que le pusimos en `tags`).
- De tipo `t2.micro`.
- En estado *running* (en ejecución) a los pocos segundos o minutos.
- Con una IP pública asignada automáticamente, que podrás usar para conectarte por SSH si la AMI lo permite (esta plantilla no configura clave SSH ni grupo de seguridad, así que por defecto el acceso remoto estará limitado).

Terraform, además, guarda en la misma carpeta un fichero `terraform.tfstate`. Este archivo es el "mapa" que usa Terraform para recordar qué ha creado y así saber qué modificar o borrar en el futuro. **No lo borres ni lo edites a mano.**

## 6. Cómo destruir los recursos creados

Una instancia EC2 en ejecución tiene coste (aunque `t2.micro` suele estar cubierta por la capa gratuita durante el primer año de la cuenta). Para evitar cargos innecesarios, destruye la instancia en cuanto termines el ejercicio:

```bash
terraform destroy
```

Terraform te mostrará qué recursos va a eliminar y pedirá confirmación con `yes`. Tras confirmar, borrará la instancia EC2 de AWS. Puedes comprobarlo en la consola: la instancia pasará a estado *terminated* y desaparecerá de la lista al cabo de un rato.
