resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "prueba-it-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "prueba-it-rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "prueba-it-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow MySQL from EKS nodes"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# AUTO-GENERATED PASSWORD
# -------------------------

resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# -------------------------
# AWS SECRETS MANAGER
# -------------------------

resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name                    = "prueba-it/rds/wordpress-credentials-${random_id.secret_suffix.hex}"
  description             = "RDS credentials for WordPress database"
  recovery_window_in_days = 0

  tags = {
    Environment = "dev"
    Project     = "prueba-it"
  }
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    host     = aws_db_instance.rds.endpoint
    port     = 3306
    dbname   = var.db_name
  })
}

# -------------------------
# RDS INSTANCE
# -------------------------

resource "aws_db_instance" "rds" {
  identifier              = "prueba-it-rds"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  username = var.db_username
  password = random_password.db_password.result
  db_name  = var.db_name

  skip_final_snapshot = true
  publicly_accessible = false
  multi_az            = false

  tags = {
    Environment = "dev"
    Project     = "prueba-it"
  }
}
