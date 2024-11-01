# variables.tf

variable "access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true  
}

variable "secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"  
}