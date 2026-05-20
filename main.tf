terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.18.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      env      = var.env
      lob      = var.lob
      provider = "aws"
      appid    = "APP-14528"
    }
  }

  ignore_tags {
    keys = [
      "domain_join",
      "fqdn",
      "nyl:appid",
    ]

    key_prefixes = [
      "nyl:platform:",
    ]
  }
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnet" "selected" {
  id = var.zscalerpa_internal_subnet_ids
}

resource "aws_security_group" "zpa_connector" {
  name        = "${var.env}-${var.lob}-zpa-connector-sg"
  description = "Security group for ZPA Connector ASG"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allow SSH from internal NYL support network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "zpa_connector" {
  name_prefix   = "${var.env}-${var.lob}-zpa-connector-"
  image_id      = var.zpa_connector_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.zpa_connector.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-${var.lob}-zpa-connector"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.env}-${var.lob}-zpa-connector"
    }
  }
}

resource "aws_autoscaling_group" "zpa_connector" {
  name                = "${var.env}-${var.lob}-zpa-connector-asg"
  min_size            = 1
  desired_capacity    = 1
  max_size            = 2
  vpc_zone_identifier = [data.aws_subnet.selected.id]

  launch_template {
    id      = aws_launch_template.zpa_connector.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.env}-${var.lob}-zpa-connector"
    propagate_at_launch = true
  }
}
