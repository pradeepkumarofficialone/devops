# Component	Details
# Creates a CloudFront distribution with default settings to serve content securely via HTTPS.
# Configures an origin using the ALB's domain (alb_domain_name) with HTTP and HTTPS ports.
# Sets a default cache behavior, redirecting all HTTP requests to HTTPS and forwarding cookies and query strings.
# Uses a free AWS-provided CloudFront default certificate for HTTPS (cloudfront_default_certificate).
# Implements georestrictions to allow traffic only from specified countries (IN, US, CA).

# # Get the certificate from AWS ACM
# data "aws_acm_certificate" "issued" {
#   domain   = var.certificate_domain_name
#   statuses = ["ISSUED"]
# }

# Creating CloudFront distribution with default settings and a free ACM certificate
resource "aws_cloudfront_distribution" "my_distribution" {
  enabled             = true
#   aliases             = [var.additional_domain_name]

  origin {
    domain_name = var.alb_domain_name
    origin_id   = var.alb_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.alb_domain_name
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
    #   restriction_type = "blacklist"  # Change this to "blacklist" to block specific countries
      locations        = ["IN", "US", "CA"]
    }
  }

  tags = {
    Name = var.project_name
  }

  viewer_certificate {
    # acm_certificate_arn      = data.aws_acm_certificate.issued.arn # Use a ACM certificate from AWS
    cloudfront_default_certificate = true # Use a default ACM certificate from AWS
    ssl_support_method             = "sni-only"
    minimum_protocol_version      = "TLSv1.2_2018"
  }
}
