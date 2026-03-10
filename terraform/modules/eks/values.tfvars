aws_region             = "eu-west-3"
cluster_name           = "prueba-it-eks"

private_subnet_ids     = [
  "subnet-aaaaaaaa",
  "subnet-bbbbbbbb",
]

eks_aws_iam_role        = "prueba-it-eks-cluster-role"
node_group_aws_iam_role = "prueba-it-eks-node-role"
node_group_name         = "prueba-it-eks-ng"

instance_type = "t3.medium"
desired_size  = 2
min_size      = 1
max_size      = 3

ebs_role_name = "prueba-it-ebs-csi-role"
