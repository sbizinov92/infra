output "repository_url" {
  description = "The URL of the echoserver repository"
  value       = aws_ecr_repository.echoserver.repository_url
}

output "repository_name" {
  description = "The name of the echoserver repository"
  value       = aws_ecr_repository.echoserver.name
}

output "repository_arn" {
  description = "The ARN of the echoserver repository"
  value       = aws_ecr_repository.echoserver.arn
}