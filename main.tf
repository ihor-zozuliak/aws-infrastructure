# REQUIREMENTS
terraform {
  required_version = "> 0.12.08"
}

# SET PROVIDER - AMAZON WEB SERVICES
provider "aws" {
  region  = var.aws-region
  version = "~> 2.43"
}

# MODULES
# module "Network" includes 
module "network" {
  source = "./modules/network/"
}
