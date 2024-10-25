


# Step 6: Create dynamic config.json using templatefile
resource "local_file" "updated_config" {
  content  = templatefile("${path.module}/config_template.json", {
    alb_dns = aws_lb.my_alb.dns_name
  })
  filename = "${path.module}/updated_config.json"
}


# Step 7: Upload updated config.json to the S3 bucket
resource "aws_s3_object" "upload_config" {
  bucket = aws_s3_bucket.example.id
  key    = "config.json" # File path in the S3 bucket
  source = local_file.updated_config.filename
}

resource "aws_s3_object" "upload_index" {
  bucket = aws_s3_bucket.example.id
  key    = "index.html"  # Name of the new file in the S3 bucket
  source = "../frontend/templates/index.html"  # Path to the local file you want to upload
}






