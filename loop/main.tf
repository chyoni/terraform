# terraform {
#   backend "s3" {
#     bucket = "cwchoiit-terraform-state-s3"
#     key = "s3-backend/terraform.tfstate"
#     region = "ap-northeast-2"
#   }
# }

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cwchoiit-terraform"

    workspaces {
      name = "cwchoiit-terraform-cloud-backend"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_iam_group" "this" {
    for_each = toset(["developer", "employee"])

    name = each.key
  
}

output "groups" {
  value = aws_iam_group.this
}

variable "users" {
    type = list(any)
}

resource "aws_iam_user" "this" {
  for_each = {
    for user in var.users : user.name => user
  }

  name = each.key

  tags = {
    level = each.value.level
    role = each.value.role
  }
}

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for user in var.users : user.name => user
  }

  user = each.key

  groups = each.value.is_developer ? [
    aws_iam_group.this["developer"].name, aws_iam_group.this["employee"].name
    ] : [
        aws_iam_group.this["employee"].name
    ]

  depends_on = [ aws_iam_user.this ] # 이 리소스가 생성되어야만 가능하게 설정
}

locals {
  developers = [
    for user in var.users : user if user.is_developer
  ]
}

# resource "aws_iam_user_policy_attachment" "developer" {
#   for_each = {
#     for user in local.developers : user.name => user
#   }

#   user = each.key
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

#   depends_on = [ aws_iam_user.this ] # 이 리소스가 생성되어야만 가능하게 설정
# }

output "developers" {
  value = local.developers
}

output "high_level_users" {
  value = [
    for user in var.users : user if user.level > 5
  ]
}