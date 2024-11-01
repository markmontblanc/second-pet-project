module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "petp-tf-bucket"
  force_destroy = true
  
  versioning = {
    enabled = true
  }

  website = {
    index_document = "index.html"
  }

  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false



  attach_policy = true
  
  policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = "*"
      Action = "s3:GetObject"
      Resource = "arn:aws:s3:::petp-tf-bucket/*"
    }
  ]
})

  tags = {
    Name = "S3 bucket"
  }
}
