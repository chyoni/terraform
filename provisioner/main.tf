provider "aws" {
  region = "ap-northeast-2"
}

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

  owners = ["099720109477"]
}

locals {
  vpc_name = "cwchoiit-vpc"
  common_tags = {
    "Project" = "provisioner-userdata"
  }
}

module "security_group" {
  source = "tedilabs/network/aws//modules/security-group"

  version = "0.24.0"

  name        = "${local.vpc_name}-provisioner-userdata"
  description = "Security Group for SSH."
  vpc_id      = "vpc-04a888e12b489eb12"

  ingress_rules = [
    {
      id          = "ssh"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from anywhere."
    },
    {
      id          = "http"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from anywhere."
    }
  ]

  egress_rules = [
    {
      id          = "all/all"
      description = "Allow to communicate to the Internet."
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  tags = local.common_tags
}

###################################################
# Userdata

# Userdata는 대부분의 운영체제에 cloud_init 이라는 패키지가 있는데 이 패키지가 부팅 시점에 Userdata를 가지고 부트스트래핑을 해준다.
# 부트스트래핑이란건 부팅 시점에 사용자 생성, 파일 구성, 소프트웨어 설치 같은 작업을 해주는데 이거는 Linux 차원에서 지원해주는 기능이라고 보면 된다.
# Userdata는 (AWS를 사용한다고 가정할 때) AMI 이미지를 가지고 첫 부팅 시점에만 실행한다.

###################################################

resource "aws_instance" "userdata" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t2.micro"
  key_name                    = "cwchoiit-ec2-keypair-home"
  subnet_id                   = "subnet-0b23fd05b5919269e"
  associate_public_ip_address = true

  user_data = <<EOT
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
EOT

  vpc_security_group_ids = [
    module.security_group.id,
  ]

  tags = {
    Name = "cwchoiit-userdata"
  }
}


###################################################
# Provisioner - in EC2

# Privisoner 라는 건 Terraform에서 공식적으로 지원해주는 Syntax.
# 세가지 대표적인 작업이 있는데 file, local_exec, remote_exec가 있다.
# file - 로컬에서 리모트로 파일을 복사
# local_exec - 로컬 PC에서 명령어 수행
# remote_exec - 리모트 머신에서 명령어 수행. 리모트 머신에서 수행하기 위해 2가지 프로토콜을 지원해준다(SSH, WinRM)
# Terraform의 Provisioner도 기본적으로는 첫 리소스 생성 시점에 실행을 할 수 있고 여러 옵션을 통해 삭제 시점이나 매번 수행할 수 있도록 커스터마이징 할 수 있다.

###################################################

# resource "aws_instance" "provisioner" {
#   ami           = data.aws_ami.ubuntu.image_id
#   instance_type = "t2.micro"
#   key_name      = "cwchoiit-ec2-keypair-home"
#   subnet_id = "subnet-0b23fd05b5919269e"
#
#   vpc_security_group_ids = [
#     module.security_group.id,
#   ]
#
#   tags = {
#     Name = "cwchoiit-provisioner"
#   }
#
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "sudo apt-get install -y nginx",
#     ]
#
#     connection {
#       type = "ssh"
#       user = "ubuntu"
#       host = self.public_ip
#     }
#   }
# }


###################################################
# Provisioner - in null-resources
###################################################

resource "aws_instance" "provisioner" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t2.micro"
  key_name                    = "cwchoiit-ec2-keypair-home"
  subnet_id                   = "subnet-0b23fd05b5919269e"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    module.security_group.id,
  ]

  tags = {
    Name = "cwchoiit-provisioner"
  }
}

resource "null_resource" "provisioner" {
  # null_resource는 triggers라는 옵션을 가지는데 이 녀석안에 있는것들이 변경되는 순간 리프로비저닝이 된다. (이 리소스 전체가)
  triggers = {
    instance_id = aws_instance.provisioner.id
    script      = filemd5("${path.module}/files/install-nginx.sh") # filemd5 - 파일 hash 값을 의미하는거
    index_file  = filemd5("${path.module}/files/index.html")       # filemd5 - 파일 hash 값을 의미하는거
  }

  provisioner "local-exec" {
    command = "echo Hello World"
  }

  provisioner "file" {
    source      = "${path.module}/files/index.html"
    destination = "/tmp/index.html"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.provisioner.public_ip
      private_key = file("${path.module}/../cwchoiit-ec2-keypair-home.pem")
    }
  }

  provisioner "remote-exec" {
    # script는 스크립트 파일을 리모트 머신에서 실행시키라는 명령어
    # inline은 내부에 명령어를 리모트 머신에서 실행시키라는 명령어
    # scripts는 스크립트 파일 복수개를 리모트 머신에서 실행시키라는 명령어
    script = "${path.module}/files/install-nginx.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.provisioner.public_ip
      private_key = file("${path.module}/../cwchoiit-ec2-keypair-home.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/index.html /var/www/html/index.html"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = aws_instance.provisioner.public_ip
      private_key = file("${path.module}/../cwchoiit-ec2-keypair-home.pem")
    }
  }
}
