## Variables file

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default = "ansbl"
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
## ami-02946ce583813a223 - CENTOS7CLEAN 
## centos7-minimal-v20190408.0.0 - ami-043171ff4488b3e87
## centos7-minimal-v20181105.0.0 - ami-0199893068f89a449
## ubuntu 16.04 - ami-0cfee17793b08a293

variable "ec2_ami" {
  description = "ansible_AMI"
  default = "ami-0199893068f89a449"
}

variable "ec2_u_ami" {
  description = "ubuntu_node_AMI"
  default = "ami-0cfee17793b08a293"
}

variable "keypair" {
  description = "Keypar for region"
  default = "mynVirginiaKP"
}

variable "aws_user" {
  description = "aws user with keys"
  default = "ec2-user"
}

variable "ssh_key_private" {
  description = "aws priv key pem"
  default = "/Users/anamikanadda/Documents/AKN_AWS/KP.pem"
}

variable "ansible_cfg" {
  description = "base ansible config file"
  default = "/Users/anamikanadda/Documents/AKN_AWS/terraform_code/ansible.cfg"
}

variable "ansible_inv" {
  description = "ansible dyn/static inventory file"
  default = "/Users/anamikanadda/Documents/AKN_AWS/terraform_code/inventory"
}

variable "repo" {
  description = "ansible lab repo"
  default = "https://github.com/ArunNadda/ansible-exam-prep"
}
