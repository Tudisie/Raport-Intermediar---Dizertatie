# S3

resource "aws_s3_bucket" "learning_platform" {
  bucket = "learning-platform-3s"

  tags = {
    Name = "LPBucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "learning_platform_ownership" {
  bucket = aws_s3_bucket.learning_platform.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "learning_platform_pab" {
  bucket = aws_s3_bucket.learning_platform.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_write_policy" {
  bucket = aws_s3_bucket.learning_platform.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::learning-platform-3s/*"
      },
      {
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "arn:aws:s3:::learning-platform-3s/*"
      }
    ]
  })

  depends_on = [aws_cloudfront_origin_access_control.cloudfront_s3_oac]
}

# Static website hosting (It's disabled while using CloudFront)

#resource "aws_s3_bucket_website_configuration" "example" {
#  bucket = aws_s3_bucket.learning_platform.id
#
#  index_document {
#    suffix = "index.html"
#  }
#}

locals {
    mime_types = {
      ".html" = "text/html"
      ".png"  = "image/png"
      ".jpg"  = "image/jpeg"
      ".gif"  = "image/gif"
      ".css"  = "text/css"
      ".js"   = "application/javascript"
    }
}

resource "aws_s3_object" "build" {
  for_each = fileset("../frontend/build/", "**")
  bucket = aws_s3_bucket.learning_platform.id
  key = each.value
  source = "../frontend/build/${each.value}"
  etag = filemd5("../frontend/build/${each.value}")
  acl    = "public-read"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.key), null)

   depends_on = [
    aws_s3_bucket.learning_platform,
    aws_s3_bucket_ownership_controls.learning_platform_ownership,
    aws_s3_bucket_public_access_block.learning_platform_pab,
    aws_s3_bucket_policy.public_write_policy
  ]
}

# CloudFront

resource "aws_cloudfront_response_headers_policy" "cors_policy" {
  name = "CORS-Policy"

  cors_config {
    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }
    access_control_allow_origins {
      items = ["*"]
    }
    access_control_allow_credentials = false
    origin_override = true
  }
}





resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
  name                              = "CloudFront S3 OAC"
  description                       = "Cloud Front S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "learning_platform_distribution" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.learning_platform.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
    origin_id   = "origin-bucket-${aws_s3_bucket.learning_platform.id}"
  }

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.learning_platform.id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400  
    
    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors_policy.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}