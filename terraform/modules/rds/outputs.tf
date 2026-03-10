output "rds_endpoint" {
  description = "RDS instance endpoint (host:port)"
  value       = aws_db_instance.rds.endpoint
}

output "rds_address" {
  description = "RDS instance hostname (without port)"
  value       = aws_db_instance.rds.address
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret containing RDS credentials"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.rds_credentials.name
}
