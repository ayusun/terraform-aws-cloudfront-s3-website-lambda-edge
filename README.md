# terraform-aws-cloudfront-s3-website-lambda-edge
Terraform 0.13.x compatible module for creating a s3 static website with cloudfront distribution, and Lambda@Edge function

The following resources will be created
  
  - S3 Bucket to store Assets
  - Cloudfront distribution
  - Route53 record
  - Lambda@Edge nodejs10.x function to redirect fqdn.com/folder/index.html request to fqdn.com/folder
  - ACM certificate for example.com (and other CNAMES)in us-east-1 region


  
Prerequisites:

  - Route 53 hosted zone for example.com
  
### Example

    provider "aws" {
      region = "us-east-1"
    }
     
    module "cloudfront_s3_website" {
        source                   = "github.com/ayusun/terraform-aws-cloudfront-s3-website-lambda-edge.git?ref=2.0.1"
        domain_name              = "example.com"
        subject_alternative_name = ["test.example.com"]
        aws_region               = "us-east-1"
    }

### Variables    
| Variable | Default | Description |
| -------- | ------- | ----------- |
| aws_region | us-east-1| AWS Region to host S3 site | 
| domain_name | None | Root of the domain|
| subject_alternative_name | [] | he alternative domains of the website, Also used to create SAN certificate |
| tags | None | Map of the tags for all resources |

### Credits
The original core 1.0.0 module was developed by [chgangaraju/terraform-aws-cloudfront-s3-website](https://github.com/chgangaraju/terraform-aws-cloudfront-s3-website)
This Fork was derieved from ver 1.2.1 module developed by [twstewart42/terraform-aws-cloudfront-s3-website-lambda-edge] (https://github.com/twstewart42/terraform-aws-cloudfront-s3-website-lambda-edge)
