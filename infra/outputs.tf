output "instance_id" {
  description = "EC2 instance ID used for SSM access"
  value       = aws_instance.docmost.id
}

output "public_ip" {
  description = "Public IPv4 address of the Docmost server"
  value       = aws_instance.docmost.public_ip
}

output "github_actions_deploy_role_arn" {
  description = "IAM role assumed by GitHub Actions for deployment"
  value       = aws_iam_role.github_actions_deploy.arn
}

output "alb_dns_name" {
  description = "DNS name of the Docmost Application Load Balancer"
  value       = aws_lb.docmost.dns_name
}
