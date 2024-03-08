provider "aws" {
	region = "ap-northeast-2"
}

resource "aws_instance" "tfec2" {
	ami = "ami-097bf0ec147165215"
	instance_type = "t2.micro"
	subnet_id = "subnet-0b23fd05b5919269e"

	tags = {
		Name = "terraform-ec2"
	}
}
