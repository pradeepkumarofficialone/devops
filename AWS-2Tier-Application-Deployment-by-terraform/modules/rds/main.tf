# Component	Details
# Creates a DB Subnet Group: Defines a group of private subnets (pri_sub_5a_id, pri_sub_6b_id) for hosting the database instance.
# Provisions a MySQL RDS Instance: Launches a db.t3.micro MySQL instance with 20GB of storage using engine version 8.0.32.
# Private and Secure: The database is not publicly accessible and is secured with the specified security group (db_sg_id).


resource "aws_db_subnet_group" "db-subnet" {
  name       = var.db_sub_name
  subnet_ids = [var.pri_sub_5a_id, var.pri_sub_6b_id] # Replace with your private subnet IDs

}

resource "aws_db_instance" "db" {
  identifier              = "bookdb-instance"
  engine                  = "mysql"
  engine_version          = "8.0.32"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = var.db_username
  password                = var.db_password
#   multi_az                = true
  multi_az                = false
  storage_type            = "gp2"
  storage_encrypted       = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 0
  vpc_security_group_ids = [var.db_sg_id] # Replace with your desired security group ID


  db_subnet_group_name = aws_db_subnet_group.db-subnet.name

  tags = {
    Name = "bookdb"
  }
}

