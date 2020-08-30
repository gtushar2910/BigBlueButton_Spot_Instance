

provider "aws" {
  region     = "us-east-1"
  access_key = file("secret_data.txt")
  secret_key = file("secret_access_data.txt")
}

module "myvpc" {
  source = "./modules/vpc"

  subnet_prefix     = var.subnet_prefix
  availability_zone = var.availability_zone
}

module "myeip" {
  source = "./modules/eipwithsg"

  vpc_id = module.myvpc.vpc_id
  subnet_id = module.myvpc.subnet_id
  private_ip_instance = var.private_ip_instance
  gateway = module.myvpc.gateway
}

module "mybbbspotinstancewithdns" {
  source = "./modules/spotinstance53"

  region = var.region1
  elasticip = module.myeip.eip_publicip
  url = var.url
  email = var.email
  ami                             = var.ami
  instance_type                   = var.bbb_spot_instance_type
  availability_zone               = var.availability_zone
  key_name                        = var.key_name
  spot_price                      = var.bbb_spot_price
  nic_id = module.myeip.nw_interface_id
  zone_id = var.hosted_zone_id
}



/* module "mybbbnormalinstancewithdns" {
  source = "./modules/normalinstance53"
  elasticip = module.myeip.eip_publicip
  url = var.url
  email = var.email
  region = var.region1
  ami                             = var.ami
  instance_type                   = var.instance_type
  availability_zone               = var.availability_zone
  key_name                        = var.key_name
  nic_id = module.myeip.nw_interface_id
  zone_id = var.hosted_zone_id
} */


