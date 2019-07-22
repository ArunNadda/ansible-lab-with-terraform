provider "aws" {
  profile = "default"
  version = "= 2.20.0"
  region = "${var.region}"
}

resource "aws_vpc" "lab-vpc" {
  cidr_block = "${var.address_space}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "${var.prefix}-lab-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id = "${aws_vpc.lab-vpc.id}"
  availability_zone = "${var.region}a"
  cidr_block = "${var.subnet_prefix1}"
  tags = {
    Name = "${var.prefix}-lab-vpc-subnet"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id = "${aws_vpc.lab-vpc.id}"
  availability_zone = "${var.region}b"
  cidr_block = "${var.subnet_prefix2}"
  tags = {
    Name = "${var.prefix}-lab-vpc-subnet"
  }
}

resource "aws_internet_gateway" "main-gw" {
  vpc_id = "${aws_vpc.lab-vpc.id}"
}

resource "aws_route_table" "main-public" {
  vpc_id="${aws_vpc.lab-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-gw.id}"
  }
}

resource "aws_route_table_association" "main-public-1-a" {
  subnet_id = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.main-public.id}"
}

resource "aws_security_group" "ansible-sg" {
  name = "${var.prefix}-sg"
  description = "Ansible SG"
  vpc_id = "${aws_vpc.lab-vpc.id}"
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "controlnode" {
  ami = "${var.ec2_ami}"
  instance_type = "${var.ec2_size}"
  subnet_id = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.ansible-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${var.keypair}"
  tags = {
    Name = "${var.prefix}-tf-ansible"
  }
 
  provisioner "remote-exec" {
    #install ansible
    inline = [
      "sudo yum -y update",
      "sudo yum -y python-virtualenv",
      "virtualenv myansible",
      "source myansible/bin/activate",
      "pip install --upgrade pip",
      "pip install ansible==2.7"
      ]
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = "${file(var.ssh_key_private)}"
    host = "${aws_instance.controlnode.public_ip}"
  }
}     

output "Ansible_Control_Node_FQDN" {
  value = "${aws_instance.controlnode.public_ip}"
}


