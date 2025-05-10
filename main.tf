terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.96.0"
    }
  }
}

provider "aws" {
  # Configuration options
}

module "aws_vpc" {
  source      = "./Modules/vpc-module"
  vpc_name    = "sandbox-vpc"
  vpc_cidr    = "10.0.0.0/16"
  environment = "sandbox"
  Owner       = "soni-devops-team"
}

module "aws_subnets" {
  source        = "./Modules/Subnets"
  vpc_id        = module.aws_vpc.vpc_id
  azs           = ["ap-south-1a", "ap-south-1b"]
  pub_sub_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  priv_sub_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  environment   = "sandbox"
  Owner         = "soni-devops-team"
}

module "SG" {
  source  = "./Modules/SG"
  vpc_id  = module.aws_vpc.vpc_id
  SG_Name = "ECS-SG"
}

module "lb" {
  source  = "./Modules/ELB"
  lb_name = "sandbox-ecs-elb"
  lb_sg   = module.SG.sg_id
  subnets = module.aws_subnets.pub_subnet_id
  tg_name = "elb-tg"
  vpc_id  = module.aws_vpc.vpc_id
}

module "ecs" {
  source           = "./Modules/ECS"
  task_def_name    = "ecs-demo-td"
  ecs_Cluster_name = "ECS-demo"
  ecs_Svc_name     = "ecs-demo-svc"
  SG_name          = module.SG.sg_id
  subnets          = module.aws_subnets.pub_subnet_id
  lb_tg_arn        = module.lb.tg_arn
  container_name   = "nginx"
  container_port   = 80
  depends_on       = [module.lb]

}