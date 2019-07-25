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
}

resource "aws_subnet" "subnet2" {
  vpc_id = "${aws_vpc.lab-vpc.id}"
  availability_zone = "${var.region}b"
  cidr_block = "${var.subnet_prefix2}"
}

resource "aws_internet_gateway" "main-gw" {
  vpc_id = "${aws_vpc.lab-vpc.id}"
  tags = {
    Name = "${var.prefix}-main-gw"
  }
}

resource "aws_route_table" "main-public" {
  vpc_id="${aws_vpc.lab-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main-gw.id}"
  }
  tags = {
    Name = "${var.prefix}-main-route"
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
  tags = {
    Name = "${var.prefix}-sg"
  }
}

# data for template file

data "template_file" "role_policy" {
  template = "${file("/Users/anamikanadda/Documents/AKN_AWS/terraform_code/04_infra/ec2_role_policy.json")}"
}

data "template_file" "control_role" {
  template = "${file("/Users/anamikanadda/Documents/AKN_AWS/terraform_code/04_infra/ec2_role_power.json")}"
}

# create role and assine profile to ec2

resource "aws_iam_role" "ctrl-node-ec2-role" {
  name = "ctrl-node-ec2-role"
  assume_role_policy = "${data.template_file.control_role.rendered}"
  tags = { Name = "${var.prefix}-role"}
}

resource "aws_iam_instance_profile" "ansible_control_profile" {
  name = "ansible_control_profile"
  role = "${aws_iam_role.ctrl-node-ec2-role.name}"
}

# create role policy
resource "aws_iam_role_policy" "ec2_admin_policy" {
  name = "ec2_admin_policy"
  role = "${aws_iam_role.ctrl-node-ec2-role.id}"
  policy = "${data.template_file.role_policy.rendered}"
}
# web node
resource "aws_instance" "node1" {
  ami = "${var.ec2_ami}"
  instance_type = "${var.ec2_size}"
  subnet_id = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.ansible-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${var.keypair}"
  count = 2
  tags = {
    Name = "${var.prefix}-web-node"
  }
}
# db node
resource "aws_instance" "node2" {
  ami = "${var.ec2_ami}"
  instance_type = "${var.ec2_size}"
  subnet_id = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.ansible-sg.id}"]
  associate_public_ip_address = "true"
  key_name = "${var.keypair}"
  count = 1
  tags = {
    Name = "${var.prefix}-db-node"
  }
}
# ctrl node
resource "aws_instance" "controlnode" {
  ami = "${var.ec2_ami}"
  instance_type = "${var.ec2_size}"
  subnet_id = "${aws_subnet.subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.ansible-sg.id}"]
  associate_public_ip_address = "true"
  iam_instance_profile = "${aws_iam_instance_profile.ansible_control_profile.name}"
  key_name = "${var.keypair}"
  tags = {
    Name = "${var.prefix}-control-node"
  }

  provisioner "file" {
    source = "${var.ansible_cfg}"
    destination = "~/ansible.cfg"
  }


  provisioner "file" {
    source = "${var.ansible_inv}"
    destination = "~/inventory"
  }

  provisioner "file" {
    source = "${var.ssh_key_private}"
    destination = "~/kp.pem"
  }
 
  provisioner "remote-exec" {
    #install ansible
    inline = [
      "sudo yum -y update",
      "sudo yum install -y python-virtualenv",
      "sudo yum install -y git",
      "virtualenv myansible",
      "source myansible/bin/activate",
      "pip install --upgrade pip",
      "pip install ansible==2.7",
      "pip install boto",
      "mkdir ansible_lab",
      "cd ansible_lab",
      "git clone ${var.repo}.git",
      "chmod 400 ~/kp.pem",
      "chmod +x ~/inventory/ec2.py"
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

output "Ansible_Control_Node_PrivateIP" {
  value = "${aws_instance.controlnode.private_ip}"
}

output "Ansible_Node_PublicIP" {
  value = "${aws_instance.node1.*.public_ip}"
}

output "Ansible_Node_PrivateIP" {
  value = "${aws_instance.node1.*.private_ip}"
}
