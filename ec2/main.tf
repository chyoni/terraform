provider "aws" {
 	region = "ap-northeast-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "terraform-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
	subnet_id = "subnet-0b23fd05b5919269e"

  tags = {
    Name = "terraform-ec2"
  }
}
