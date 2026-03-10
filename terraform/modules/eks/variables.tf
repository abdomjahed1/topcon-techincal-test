variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "eks_version" {
  type        = string
  description = "EKS version"
  default     = "1.29"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs where EKS will run"
}

variable "eks_aws_iam_role" {
  type        = string
  description = "IAM role name for EKS cluster"
}

variable "node_group_aws_iam_role" {
  type        = string
  description = "IAM role name for EKS node group"
}

variable "permissions_boundary" {
  type        = string
  description = "Permissions boundary ARN"
  default     = null
}

variable "node_group_name" {
  type        = string
  description = "Node group name"
}

variable "instance_type" {
  type        = string
  description = "Instance type for worker nodes"
  default     = "t3.small"
}

variable "desired_size" {
  type        = number
  default     = 1
}

variable "min_size" {
  type        = number
  default     = 1
}

variable "max_size" {
  type        = number
  default     = 3
}

variable "capacity_type" {
  type        = string
  description = "Capacity type for worker nodes (ON_DEMAND or SPOT)"
  default     = "SPOT"
}

variable "ebs_role_name" {
  type        = string
  description = "IAM role name for EBS CSI driver"
}
