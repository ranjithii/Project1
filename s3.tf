resource "aws_s3_bucket" "static_content" {
  bucket = "my-static-content-bucket"
  #acl    = "public-read"
}
