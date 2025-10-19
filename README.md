# iTop AMI con Packer y Terraform en AWS
Repositorio para lanzar ami de iTop usando Terraform para una instancia EC2.

## 1. Configurar usuario de IAM en AWS
  1. `IAM` -> `Users` -> `Add user`
  2. Nombre de usuario: `your-username` -> Next
  3. Permissions options: Add user to group -> Next -> Create user
  4. Ve a `your-username`:
      - `Permissions` -> `Permissions policies`
      - `Add permissions` -> `Create inline policy` -> `JSON`
      - Ve a `/docs/packer-iam-policy.json`, copia el contenido y pégalo en el `Policy Editor`
      - Crea otra inline policy repitiendo el paso anterior pero esta vez:
        - Ve a `/docs/terraform-iam-policy.json`, copia el contenido y pégalo en el `Policy Editor`
  5. Ve a `your-username` -> `Security credentials` -> `Create access key`
      - Command line interface -> Next
      - Copia Access key ID y Secret access key
  6. En la terminal local ejecuta `aws configure` e ingresa las claves copiadas

Necesitarás ajustar estos valores según tu setup:
- `tu-ssh-keypair`: nombre de tu key pair
- `Packer`&`Terraform` instalado y configurado con `AWS CLI`
- Tener los permisos necesario para crear la infrastructura en AWS


## 2. Lanzar la instancia
```bash
# Clonar el repositorio de Terraform
git clone https://github.com/keaguirre/terraform-itop-deploy

cd terraform-itop-deploy

# Inicializar Terraform
terraform init

# Aplicar la configuración (ajusta variables según tu setup)
terrafom apply --auto-approve -var="key_name=tu-ssh-keypair"

# Eliminar la infraestructura creada
terrafom destroy --auto-approve -var="key_name=tu-ssh-keypair"
```

## 3. Validación de la Instalación
Terraform al finalizar mostrará la IP pública de la instancia + el comando SSH para conectarse. Usa esa información para conectarte.

> [!NOTE]  
> Necesitarás la clave privada `.pem` asociada al key pair usado + permisos adecuados en el archivo `.pem`.
### Windows: 

  ```powershell
  # Quitar herencia de permisos
  icacls .\key.pem /inheritance:r

  # Conceder solo permiso de lectura al usuario actual (reemplaza permisos existentes para ese usuario)
  icacls .\key.pem /grant:r "$($env:USERNAME):R"

  # Verificar permisos
  icacls .\key.pem
```
### Linux:
```bash
# Ajustar permisos
chmod 400 ./key.pem

# Verificar permisos
ls -l ./key.pem 
```

## 4. Comandos de validación en la instancia
```bash
# Configuracion manual de DB Externa (Railway)
domain:port
root_user
root_password
new_db_name #Verifica que el schema con este nombre no exista previamente

# Validar la salida del script de user-data
sudo tail -n 300 /var/log/user-data.log

# Validar el montaje del volumen adicional
df -hT

# Ubicación de config file de iTop
cat /var/www/itop/web/conf/production/config-itop.php
```

## 5. Diagrama de Arquitectura
```mermaid
flowchart TD
  A[Developer] -->|init plan apply| B[Terraform]

  %% Terraform necesita un perfil con permisos
  B -->|usa credenciales| IAM_TF[IAM Role o User con permisos de administración en AWS]
  IAM_TF --> AWS[AWS]

  %% Terraform provee el script a la instancia
  B -->|entrega| UD[user_data.sh instala y configura iTop]

  subgraph AWS Account
    direction TB

    subgraph Networking
      SUBNET[Subnet pública]
      ROUTE[Route Table con salida a IGW]
      IGW[Internet Gateway]
      SG[Security Group puertos 80, 443]
      SUBNET --- ROUTE
      ROUTE --- IGW
    end

    EC2[EC2 Instance servidor iTop]
    IPROFILE[IAM Instance Profile para la instancia]
  end

  %% Relaciones principales
  B -->|crea| SG
  B -->|crea| EC2
  B -->|asigna| IPROFILE
  SG --> EC2
  SUBNET -.-> EC2
  IPROFILE -.-> EC2
  UD -->|se ejecuta al iniciar| EC2

  %% Outputs visibles
  EC2 --> OUTS[Salidas del despliegue]
  OUTS --> OUT1[Dirección IP pública del servidor]
  OUTS --> OUT2[URL de acceso a iTop HTTP/HTTPS]
  OUTS --> OUT3[Credenciales iniciales o token de acceso]
  OUTS --> OUT4[Nombre de la instancia y región]

  classDef optional stroke-dasharray: 4 3,stroke:#999
  class IPROFILE optional

```