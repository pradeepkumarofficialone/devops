variable alb_sg_id {}
variable pub_sub_1a_id {}
variable pub_sub_2b_id {}
variable vpc_id {}
variable "project_name" {
  default     = "AWS-ALB" # it should be less than 32 characters
  description = "Project name"
  type        = string
}




