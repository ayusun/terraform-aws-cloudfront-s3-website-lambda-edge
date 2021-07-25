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

variable "custom_origins" {
  description = "List of custom origin that Cloudfront may support. By Default a S3 origin will be created for static website"
  default     = []
  type = list(object({
    domain_name = string
    origin_id   = string
    origin_path = string
  }))
}

variable "ordered_cache_behaviour" {
  description = "Precedence in cache behaviour"
  default     = []
  type = list(object({
    allowed_methods          = list(string)
    target_origin_id         = string
    path_pattern             = string
    viewer_protocol_policy   = string
    cache_policy_id          = string
    origin_request_policy_id = string
  }))
}

variable "tags" {
  default     = {}
  description = "Map of the tags for all resources"
  type        = map
}


