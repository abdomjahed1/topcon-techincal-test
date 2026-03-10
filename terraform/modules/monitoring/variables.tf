variable "alert_email" {
  type        = string
  description = "Email address to receive infrastructure alert notifications"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name for CloudWatch dimensions"
}

variable "rds_identifier" {
  type        = string
  description = "RDS instance identifier for CloudWatch dimensions"
  default     = "prueba-it-rds"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}
