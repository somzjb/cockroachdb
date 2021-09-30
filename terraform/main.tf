terraform {
 backend "s3" {
        bucket = "{s3_bucket}"
        key = "{s3_object_key}"
        region = "us-east-1"
        profile = "default"      
    }
}   


#----------------Define Providers-------------#
provider "aws" {
    region = var.region
    profile = "default"
    
}


#---------------Spin-Up EC2 -------------#
module "ec2" {
    source = "./modules/spin_ec2"
    instance_size = var.instance_size
    target_vpc = var.target_vpc
    db_server_count = var.db_server_count
    keypair = var.keypair
    security_group = var.security_group
    
}


#-------------Define networking--------------#
module "networking" {
   source = "./modules/sg_rules"
   target_vpc = var.target_vpc
   security_group = var.security_group
   app_access_rule = var.app_access_rule
}

#-------------Network Load Balancer-------------#
module "nlb" {
   source = "./modules/nlb"
   security_group = var.security_group
   target_vpc = var.target_vpc
   target_group = module.nlb_target_group.target_group
}

module "nlb_target_group" {
   source = "./modules/target_group"
   vpc_id = module.ec2.vpc_id
   ec2_id = module.ec2.ec2_id_name
}

#--------------declare variables------------#
variable "instance_size" {}
variable "region" {}
variable "db_server_count" {}
variable "target_vpc" {}
variable "keypair" {}
variable "security_group" {}
variable "app_access_rule" {
  type = list(string)
}

output "ec2_instances" {
    value = module.ec2.ec2_ids
}

output "elb_dns_name" {
    value = module.nlb.elb_dns_name
}
