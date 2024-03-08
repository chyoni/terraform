provider "local" {}

provider "aws" {
  region = "ap-northeast-2"
}

resource "local_file" "foo" {
  content  = "Hello World!"
  filename = "${path.module}/foo.txt"
}

data "local_file" "bar" {
  filename = "${path.module}/bar.txt"
}

output "file_bar" {
  value = data.local_file.bar
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "Terraform"
  }
}

output "aws_vpc" {
  value = aws_vpc.vpc
}

data "aws_vpcs" "vpcs" {}

output "vpcs" {
  value = data.aws_vpcs.vpcs
}
