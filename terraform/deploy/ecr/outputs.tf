output "repository_url" {
  description = "The URL of the echoserver repository"
  value       = module.ecr.repository_url
}

output "repository_name" {
  description = "The name of the echoserver repository"
  value       = module.ecr.repository_name
}

output "repository_arn" {
  description = "The ARN of the echoserver repository"
  value       = module.ecr.repository_arn
}