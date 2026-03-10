variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "eks_node_sg_id" {
  type = string
}

variable "db_username" {
  type    = string
  default = "wpuser"
}

variable "db_name" {
  type    = string
  default = "wordpress"
}
