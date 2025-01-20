# Component	Details
# Creates a Secret in AWS Secrets Manager: Provisions a Secrets Manager secret with the name specified in var.secret_name to store database credentials securely.
# Stores Secret Version: Adds a version to the secret with a JSON-encoded string containing the database username and password.
# Secure Storage: Ensures sensitive database credentials are securely stored and managed.
# Ease of Access: Secrets can be retrieved programmatically, reducing hardcoding sensitive information in configurations.

resource "aws_secretsmanager_secret" "my_database_secret" {
  name        = var.secret_name
  description = "RDS database credentials"
}

resource "aws_secretsmanager_secret_version" "my_database_secret_version" {
  secret_id     = aws_secretsmanager_secret.my_database_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
