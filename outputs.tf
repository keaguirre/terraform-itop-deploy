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
  description = "Comando SSH usando la Elastic IP"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_eip.itop.public_ip}"
}

output "ami_id" {
  description = "ID de la AMI utilizada"
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

output "efs_id" {
  description = "ID del sistema de archivos EFS"
  value       = aws_efs_file_system.itop.id
}

output "efs_dns_name" {
  description = "DNS name del EFS"
  value       = aws_efs_file_system.itop.dns_name
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}
