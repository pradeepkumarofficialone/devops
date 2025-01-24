output "rds_database_secret_arn" {
  value = aws_secretsmanager_secret.my_database_secret.arn
}

output "rds_database_secret_name" {
  value = aws_secretsmanager_secret.my_database_secret.name
}
