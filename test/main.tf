# The profile needs to be set using the access keys provided
provider "aws" {
  profile     = "${var.aws_profile}"
  region      = "${var.aws_region}"
}

# Sandpit VPC
module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "1.30.0"

  name                    = "seclocker-test"
  cidr                    = "192.168.0.0/16"

  # No multi-az at this point
  azs                     = ["eu-west-1a"]
  # TODO: remove the secondary subnets part before giving to candidate to make the provisioning fail
  #       alternatively: uncomment the secondary subnets
  public_subnets          = ["192.168.0.0/20"]  
  map_public_ip_on_launch = true

  tags = {
    Terraform   = "true"
    Environment = "test"
  }

  vpc_tags = {
    owner         = "${var.owner}"
    owner.email   = "${var.owner_email}"
  }
}

##########################################
# Two linux instances doing nothing ...
#################################

####################
# Instance config
############
data "template_file" "userdata" {
  template = "${file("templates/userdata.tpl")}"
  vars {
    ssh_access_config_location = "${var.ssh_access_config_location}"
    aws_region = "${var.aws_region}"
  }
}

data "template_file" "cloud_config" {
  template = "${file("templates/cloud-config.tpl")}"
  vars {
    ssh_access_config_location = "${var.ssh_access_config_location}"
    ws_log_group = "ws_log"
  } 
}

data "template_cloudinit_config" "config" {
  # This is the userdata
  part {
    content_type  = "text/cloud-config"
    content       = "${data.template_file.cloud_config.rendered}"
  }

  # This is the userdata
  part {
    content_type  = "text/x-shellscript"
    content       = "${data.template_file.userdata.rendered}"
  }
}

resource "aws_security_group" "sshaccess" {
  name        = "ssh_access"
  description = "Allow SSH from selected sources"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_ingress_cidr}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

##############
# Instances
#####
resource "aws_instance" "ws" {
  count = "1"
  ami = "ami-bff32ccc"
  instance_type = "t2.micro"
  subnet_id = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.sshaccess.id}"]
  associate_public_ip_address = true
  key_name = "${var.ssh_key_name}"
  iam_instance_profile = "${var.ws_log_instance_profile}"

  user_data = "${data.template_cloudinit_config.config.rendered}"

  tags = {
    Name          = "webserver-${count.index}"
    Terraform     = "true"
    Environment   = "test"
    owner         = "${var.owner}"
    owner.email   = "${var.owner_email}"
  }
}