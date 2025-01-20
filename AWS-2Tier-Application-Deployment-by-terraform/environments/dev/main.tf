# Component	Details
# VPC Module: Creates a Virtual Private Cloud (VPC) with multiple public and private subnets for different availability zones, defining the VPC CIDR block and subnet CIDR ranges.
# NAT Module: Configures NAT Gateways for private subnets, allowing outbound internet access from private instances.
# Security Group Module: Sets up security groups for controlling inbound and outbound traffic for different resources like the ALB, clients, and databases.
# Key Module: Generates SSH key pairs for secure access to instances.
# ALB Module: Deploys an Application Load Balancer (ALB) with necessary security groups and subnet associations.
# Auto Scaling Group (ASG) Module: Creates an ASG for automatic scaling of instances behind the ALB, with proper security group associations and subnet mappings.
# Secrets Manager Module: Manages sensitive information like database credentials (username and password).
# RDS Module: Deploys an RDS instance, using secrets from Secrets Manager for database credentials and configuring security groups and subnets.
# CloudFront Module: Creates a CloudFront distribution with the ALB as the origin for better performance and secure content delivery.
# Bastion Server Module: Launches a Bastion Host in a public subnet for secure access to private instances via SSH.


module "vpc" {
    source = "../../modules/vpc"
    region = var.region
    project_name = var.project_name
    vpc_cidr         = var.vpc_cidr
    pub_sub_1a_cidr = var.pub_sub_1a_cidr
    pub_sub_2b_cidr = var.pub_sub_2b_cidr
    pri_sub_3a_cidr = var.pri_sub_3a_cidr
    pri_sub_4b_cidr = var.pri_sub_4b_cidr
    pri_sub_5a_cidr = var.pri_sub_5a_cidr
    pri_sub_6b_cidr = var.pri_sub_6b_cidr
}

module "nat" {
  source = "../../modules/nat"
  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  igw_id        = module.vpc.igw_id
  pub_sub_2b_id = module.vpc.pub_sub_2b_id
  vpc_id        = module.vpc.vpc_id
  pri_sub_3a_id = module.vpc.pri_sub_3a_id
  pri_sub_4b_id = module.vpc.pri_sub_4b_id
  pri_sub_5a_id = module.vpc.pri_sub_5a_id
  pri_sub_6b_id = module.vpc.pri_sub_6b_id
}

# creating security groups
module "security-group" {
  source = "../../modules/security-group"
  vpc_id = module.vpc.vpc_id
}

# creating Key for instances
module "key" {
  source = "../../modules/key"
}

# Creating Application Load balancer
module "alb" {
  source         = "../../modules/alb"
  alb_sg_id      = module.security-group.alb_sg_id
  pub_sub_1a_id = module.vpc.pub_sub_1a_id
  pub_sub_2b_id = module.vpc.pub_sub_2b_id
  vpc_id         = module.vpc.vpc_id
}

module "asg" {
  source         = "../../modules/asg"
  project_name   = module.vpc.project_name
  key_name       = module.key.key_name
  client_sg_id   = module.security-group.client_sg_id
  pri_sub_3a_id  = module.vpc.pri_sub_3a_id
  pri_sub_4b_id  = module.vpc.pri_sub_4b_id
  tg_arn         = module.alb.tg_arn
}

# Call Secrets Manager Module
module "secrets_manager" {
  source     = "../../modules/secrets_manager"
  db_username = var.db_username
  db_password = var.db_password
}


# creating RDS instance

module "rds" {
  source         = "../../modules/rds"
  db_sg_id       = module.security-group.db_sg_id
  pri_sub_5a_id  = module.vpc.pri_sub_5a_id
  pri_sub_6b_id  = module.vpc.pri_sub_6b_id
  db_username    = var.db_username
  db_password    = var.db_password
}

# create cloudfront distribution 
module "cloudfront" {
  source = "../../modules/cloudfront"
  # certificate_domain_name = var.certificate_domain_name
  alb_domain_name = module.alb.alb_dns_name
  # additional_domain_name = var.additional_domain_name
  project_name = module.vpc.project_name
}

# launching JUMP server or Bastion host 
module "bastion_server" {
  source         = "../../modules/bastion_server"
  bastion_sg_id  = module.security-group.bastion_sg_id
  pub_sub_1a_id  = module.vpc.pub_sub_1a_id
  key_name       = module.key.key_name
} 