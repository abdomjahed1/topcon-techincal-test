provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "eks"
  region = var.aws_region
}

# -------------------------
# IAM ROLES
# -------------------------

resource "aws_iam_role" "eks_cluster_role" {
  provider = aws.eks
  name     = var.eks_aws_iam_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  provider   = aws.eks
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_role" {
  provider = aws.eks
  name     = var.node_group_aws_iam_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "node_policy_ecr_attachment" {
  provider   = aws.eks
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_policy_cni_attachment" {
  provider   = aws.eks
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_policy_worker_attachment" {
  provider   = aws.eks
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# -------------------------
# EKS CLUSTER
# -------------------------

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }
}

# -------------------------
# NODE GROUP
# -------------------------

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  capacity_type  = var.capacity_type
  instance_types = [var.instance_type]

  labels = {
    "capacity-type" = var.capacity_type
  }
}

# -------------------------
# OIDC + EBS CSI DRIVER (IRSA)
# -------------------------

data "aws_eks_cluster" "my_cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = data.aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = var.ebs_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "${replace(data.aws_eks_cluster.my_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_role.name
}

