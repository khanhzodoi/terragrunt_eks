output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = try(aws_db_instance.this.endpoint, "")
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = try(aws_db_instance.this.address, "")
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = try(aws_db_instance.this.arn, "")
}