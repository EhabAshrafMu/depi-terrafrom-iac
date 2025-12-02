variable "aws_region" {
  description = "AWS region for deploying the resources."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The envirnment used. Since this is a capstone project, it's only production for now."
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}


variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "django_secret_key" {
  description = "Django secret key"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/MahmoudGShake/Automated-Application-Deployment.git"
}

variable "project_tags" {
  type = map(string)
  default = {
    "project" = "DEPI-Project"
  }
}

variable "my_ip" {
  description = "my IP address"
  type        = string
  sensitive   = true
}