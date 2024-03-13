terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cwchoiit-terraform"

    workspaces {
      name = "openvpn"
    }
  }
}

locals {
  context = yamldecode(file(var.config_file)).context
  config  = yamldecode(templatefile(var.config_file, local.context))
}

provider "aws" {
  region = "ap-northeast-2"
}
