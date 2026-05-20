variable "instance_type" {
  description = "Type of EC2 instance to use"
  type        = string
  default     = "t3.micro"
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "lob" {
  description = "Line of business"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to deploy into"
  type        = string
}

variable "zscalerpa_internal_subnet_ids" {
  description = "Subnet ID in the single AZ to use"
  type        = string
}

variable "zpa_connector_ami_id" {
  description = "AMI ID for Zscaler Private Access Connector"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "Internal corporate CIDR ranges allowed to SSH to the ZPA connector private IP."
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "192.168.0.0/16",
    "172.16.0.0/12"
  ]

  validation {
    condition = alltrue([
      for cidr in var.ssh_allowed_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All ssh_allowed_cidrs values must be valid CIDR blocks."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access."
  type        = string
}
