variable "subnet_prefix"{
  description = "cidr block for subnet"
}

variable "hosted_zone_id"{
  description = "DNS Zone"
}

variable "ami"{
  description = "image id"
}

variable "region1"{
  description = "default region"
}

variable "key_name"{
  description = "SSH Key"
}

variable "email"{
  description = "email"
}

variable "private_ip_instance"{
  description = "Private IP of the Instance"
}

variable "url"{
  description = "URL"
}

variable "instance_type"{
  description = "Type of the Instance"
}

variable availability_zone{
  description = "Availibility Zone"
}

variable bbb_spot_price{
  description = "BBB Spot Price"
}

variable bbb_spot_instance_type{
  description = "BBB Spot Instance Type"
}