locals {
  project     = "terraform-lab"
  environment = "dev"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "eddie-terraform-state-023703349324"
    key          = "terraform-aws-lab/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = module.network.public_subnet_id
  vpc_security_group_ids      = [module.network.web_security_group_id]
  user_data_replace_on_change = true

  user_data = <<-EOF
  #!/bin/bash
  dnf install -y nginx
  systemctl enable nginx
  systemctl start nginx
  echo "Hello from Terraform!" > /usr/share/nginx/html/index.html
EOF

  tags = merge(
    local.common_tags,
    {
      Name = "${local.project}-web"
    }
  )
}

module "network" {
  source = "./modules/network"

  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"

  project_name = local.project
  common_tags  = local.common_tags
}