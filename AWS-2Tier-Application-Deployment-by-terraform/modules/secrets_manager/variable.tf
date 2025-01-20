variable "secret_name" {
  description = "The name of the secret"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the RDS database"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}
