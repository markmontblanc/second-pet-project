

# Створення бакету
resource "aws_s3_bucket" "example" {
  bucket = "petp-tf-bucket-${terraform.workspace}"

  force_destroy = true
}

# Додання можливості static website hosting
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id  

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Додання полісі щоб не було 404
resource "aws_s3_bucket_policy" "front_bucket_policy" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::petp-tf-bucket-${terraform.workspace}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.example]
}








# OAI дозволяє CloudFront отримувати доступ до об'єктів в S3-бакеті без необхідності робити бакет публічно доступним
resource "aws_cloudfront_origin_access_identity" "example" {
  comment = "OAI for my S3 bucket in ${terraform.workspace} environment"
}




# Створення CloudFront Distribution
resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = aws_s3_bucket.example.bucket_regional_domain_name
    origin_id   = "s3-origin-${terraform.workspace}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for S3 - ${terraform.workspace}"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "s3-origin-${terraform.workspace}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"  # Перенаправляємо HTTP на HTTPS
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  viewer_certificate {
    cloudfront_default_certificate = true  # Використовуємо стандартний сертифікат CloudFront для HTTPS
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "CloudFront distribution for S3 - ${terraform.workspace}"
  }
}



