variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "cluster_name" {
  type    = string
  default = "prueba-it-eks"
}

variable "domain_name" {
  type    = string
  default = "abdo-devops.com"
}

variable "db_username" {
  type = string
}

variable "db_name" {
  type    = string
  default = "wordpress"
}
variable "ecr_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "alert_email" {
  type        = string
  description = "Email address for infrastructure alert notifications"
}
