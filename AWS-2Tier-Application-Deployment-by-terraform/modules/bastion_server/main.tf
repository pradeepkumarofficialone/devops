# Component	Details
# Launches an EC2 instance named bastion_server in the public subnet (pub_sub_1a_id).
# Uses specified AMI (ami), instance type (cpu), and security group (bastion_sg_id).
# Configures SSH access with the provided key pair (key_name).
# Tags the instance for identification as bastion_server.

# launch the ec2 instance in pub-sub-1-a
resource "aws_instance" "bastion_server" {
  ami                    = var.ami
  instance_type          = var.cpu
  subnet_id              = var.pub_sub_1a_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.key_name

  tags = {
    Name = "bastion_server"
  }
}

