variable "aws_region" {
  description = "Región de AWS donde desplegar la infraestructura"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Nombre del proyecto (usado para nombrar recursos)"
  type        = string
  default     = "itop-lab"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod, lab)"
  type        = string
  default     = "lab"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para iTop"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Nombre del key pair de AWS para acceso SSH"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "Lista de CIDRs permitidos para SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Cambiar por tu IP específica en producción
}