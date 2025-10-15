# =====================================================
# Outputs principales del despliegue de iTop en AWS
# =====================================================

output "instance_id" {
  description = "ID de la instancia EC2 iTop"
  value       = aws_instance.itop.id
}

output "instance_private_ip" {
  description = "Dirección IP privada de la instancia EC2"
  value       = aws_instance.itop.private_ip
}

output "instance_public_ip" {
  description = "Elastic IP asociada a la instancia EC2 (IP pública fija)"
  value       = aws_eip.itop.public_ip
}

output "itop_url" {
  description = "URL pública para acceder a iTop (usa Elastic IP)"
  value       = "http://${aws_eip.itop.public_ip}/"
}

output "ssh_command" {
  description = "Comando para conectarse por SSH usando la Elastic IP"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.itop.public_ip}"
}

# =====================================================
# Información de la AMI
# =====================================================

output "ami_id" {
  description = "ID de la AMI utilizada para crear la instancia"
  value       = data.aws_ami.itop.id
}

output "ami_name" {
  description = "Nombre de la AMI utilizada"
  value       = data.aws_ami.itop.name
}

output "ami_creation_date" {
  description = "Fecha de creación de la AMI"
  value       = data.aws_ami.itop.creation_date
}

# =====================================================
# Información de EFS y red
# =====================================================

output "efs_id" {
  description = "ID del sistema de archivos EFS usado por iTop"
  value       = aws_efs_file_system.itop.id
}

output "efs_dns_name" {
  description = "Nombre DNS del sistema de archivos EFS"
  value       = aws_efs_file_system.itop.dns_name
}

output "vpc_id" {
  description = "ID de la VPC donde se desplegó la instancia"
  value       = aws_vpc.main.id
}

# =====================================================
# Resumen general
# =====================================================

output "summary" {
  description = "Resumen general del despliegue de iTop"
  value = <<EOT

🔹 Proyecto: ${var.project_name}
🔹 Entorno: ${var.environment}
🔹 Región AWS: ${var.aws_region}

🖥️ Instancia EC2
   - ID: ${aws_instance.itop.id}
   - Elastic IP: ${aws_eip.itop.public_ip}
   - SSH: ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.itop.public_ip}

📦 AMI Base
   - ID: ${data.aws_ami.itop.id}
   - Nombre: ${data.aws_ami.itop.name}
   - Creada: ${data.aws_ami.itop.creation_date}

📂 EFS
   - ID: ${aws_efs_file_system.itop.id}
   - DNS: ${aws_efs_file_system.itop.dns_name}

🌐 URL iTop
   - http://${aws_eip.itop.public_ip}/

EOT
}
