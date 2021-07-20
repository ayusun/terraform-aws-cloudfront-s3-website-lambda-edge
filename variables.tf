variable "aws_region" {
  default     = "us-east-1"
  description = "AWS Region to host S3 site"
  type        = string
}

variable "domain_name" {
  description = "Root of the domain"
  type        = string
}

variable "subject_alternative_name" {
  description = "The alternative domains of the website, Also used to create SAN certificate"
  type        = list(string)
  default     = []
}

variable "tags" {
  default     = {}
  description = "Map of the tags for all resources"
  type        = map
}


