output "web_public_ip" {
  description = "Public IP of the web EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_public_dns" {
  description = "Public DNS name of the web EC2 instance"
  value       = aws_instance.web.public_dns
}