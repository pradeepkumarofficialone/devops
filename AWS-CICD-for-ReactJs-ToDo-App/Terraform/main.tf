provider "aws" {
    region = "us-east-1"
}

resource "aws_key_pair" "my-key" {
    key_name = "my-key"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "jenkins_server" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro" 
    key_name = aws_key_pair.my-key.key_name
    vpc_security_group_ids = [aws_security_group.SG.id]
    tags = {
        Name = "Jenkins"
    }
}

resource "aws_instance" "cd_server" {
    ami = "ami-053b0d53c279acc90"
    instance_type = "t2.micro"
    key_name = aws_key_pair.my-key.key_name
    vpc_security_group_ids = [aws_security_group.SG.id]
    tags = {
        Name = "CD-Server"
    }
}

# Fetch the Default VPC ID
data "aws_vpc" "default" {
    default = true
}

resource "aws_security_group" "SG" {
    name = "CICD-SG"
    vpc_id = data.aws_vpc.default.id

    # Ingress Rule: Allow HTTP
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Ingress Rule: Allow SSH
    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    

    tags = {
    Name = "CICD-SG"
    }
  
}
# Define path varaib for Ansible & inventory files
locals {
  Ansible_inventory_path = "~/Desktop/git/AWS-CICD-for-ReactJs-ToDo-App/Ansible/inventory.ini"
  Ansbile_playbook_path = "~/Desktop/git/AWS-CICD-for-ReactJs-ToDo-App/Ansible/playbook.yml"
}

# Create an inventory file dynamically with EC2 instance IPs
resource "null_resource" "update_inventory" {
  depends_on = [
    aws_instance.jenkins_server,
    aws_instance.cd_server
  ]

  provisioner "local-exec" {
    command = <<EOT
      echo "ssh-keyscan -H ${aws_instance.jenkins_server.public_ip}" >> ~/.ssh/known_hosts
      echo "ssh-keyscan -H ${aws_instance.cd_server.public_ip}" >> ~/.ssh/known_hosts
      echo "[jenkins_server]" > ${local.Ansible_inventory_path}
      echo "${aws_instance.jenkins_server.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ${local.Ansible_inventory_path}
      echo "[cd_server]" >> ${local.Ansible_inventory_path}
      echo "${aws_instance.cd_server.public_ip} ansible_ssh_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ${local.Ansible_inventory_path}
    EOT
  }
}

# Use local-exec to run Ansible playbook
resource "null_resource" "run-ansible-playbook" {
    depends_on = [null_resource.update_inventory]

    provisioner "local-exec" {
        command = "ansible-playbook -i ${local.Ansible_inventory_path} ${local.Ansbile_playbook_path}"
      
    }
  
}
