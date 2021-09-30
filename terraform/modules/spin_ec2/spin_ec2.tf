data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "target_vpc" {
  tags = {
    Name = "${var.target_vpc}"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.target_vpc.id
  tags = {
    tier = "db"
  }
}

data "aws_security_group" "sg" {
  name = "${var.security_group}"
  vpc_id = data.aws_vpc.target_vpc.id
}

resource "aws_instance" "db_instance" {
  count         = "${var.db_server_count}"
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_size}"
  subnet_id     = "${element(tolist(data.aws_subnet_ids.private.ids), count.index)}"
  key_name      = "${var.keypair}"
  vpc_security_group_ids =[data.aws_security_group.sg.id]
}


variable "instance_size" {}
variable "target_vpc" {}
variable "db_server_count" {}
variable "keypair" {}
variable "security_group" {}

output "ec2_ids" {
    value = aws_instance.db_instance.*.public_ip
}
output "ec2_id_name" {
    value = aws_instance.db_instance.*.id
}
output "vpc_id" {
    value = data.aws_vpc.target_vpc.id
}
