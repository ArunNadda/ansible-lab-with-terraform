## Variables file

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "region" {
  description = "The Amazon region to use"
  default = "us-east-1"
}

variable "address_space" {
  description = "vpc address space"
  default = "10.0.0.0/16"
}

variable "subnet_prefix1" {
  description = "address prefix for subnet1"
  default = "10.0.10.0/24"
}

variable "subnet_prefix2" {
  description = "address prefix for subnet1"
  default = "10.0.11.0/24"
}

variable "ec2_size" {
  description = "size of EC2"
  default = "t2.micro"
}

variable "ec2_ami" {
  description = "ansible_AMI"
  default = "ami-035b3c7efe6d061d5"
}

variable "keypair" {
  description = "Keypar for region"
  default = "mynVirginiaKP"
}

variable "aws_user" {
  description = "aws user with keys"
  default = "ec2-user"
}

