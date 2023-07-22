# Example Bucket #1 
resource "aws_s3_bucket" "example_01" {
  bucket = "example-bucket-01-${random_string.deploy_id.result}"
}

resource "aws_s3_bucket_ownership_controls" "example_01" {
  bucket = aws_s3_bucket.example_01.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example_01" {
  depends_on = [aws_s3_bucket_ownership_controls.example_01]

  bucket = aws_s3_bucket.example_01.id
  acl    = "private"
}

# Example Bucket #2 
resource "aws_s3_bucket" "example_02" {
  bucket = "example-bucket-02-${random_string.deploy_id.result}"
}

resource "aws_s3_bucket_ownership_controls" "example_02" {
  bucket = aws_s3_bucket.example_02.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example_02" {
  depends_on = [aws_s3_bucket_ownership_controls.example_01]

  bucket = aws_s3_bucket.example_02.id
  acl    = "private"
}

# Example Bucket #3
resource "aws_s3_bucket" "example_03" {
  bucket = "example-bucket-03-${random_string.deploy_id.result}"
}

resource "aws_s3_bucket_ownership_controls" "example_03" {
  bucket = aws_s3_bucket.example_03.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example_03" {
  depends_on = [aws_s3_bucket_ownership_controls.example_01]

  bucket = aws_s3_bucket.example_03.id
  acl    = "private"
}



