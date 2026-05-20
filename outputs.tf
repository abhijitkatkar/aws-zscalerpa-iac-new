output "vpc_id" {
  value = data.aws_vpc.selected.id
}

output "subnet_id" {
  value = data.aws_subnet.selected.id
}

output "selected_availability_zone" {
  value = data.aws_subnet.selected.availability_zone
}

output "zpa_connector_ami_id" {
  value = var.zpa_connector_ami_id
}

output "asg_name" {
  value = aws_autoscaling_group.zpa_connector.name
}
