variable "aws_region" {
  type        = string
  description = "Target AWS Region for deployment"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance size for running tools"
  default     = "t3.medium" # Provides 2 vCPUs and 4GB RAM required for runner engines
}

variable "environment_tag" {
  type        = string
  description = "Resource environment categorization"
  default     = "DevSecOps-Pipeline"
}
