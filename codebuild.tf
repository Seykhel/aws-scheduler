# S3 Bucket for storing Lambda function code and other artifacts
# This bucket is used to store deployment packages and other build artifacts
resource "aws_s3_bucket" "artifacts" {
  # Generate a unique bucket name with a timestamp-based suffix
  bucket_prefix = "aws-scheduler-artifacts-"
  
  # Allow the bucket to be destroyed even if it contains objects
  # WARNING: Only enable this in development environments
  force_destroy = true
  
  # Add tags for better resource management and cost allocation
  tags = {
    Name        = "aws-scheduler-artifacts"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Configure basic access control for the S3 bucket
resource "aws_s3_bucket_acl" "artifacts_acl" {
  # Reference the S3 bucket created above
  bucket = aws_s3_bucket.artifacts.id
  
  # Set the bucket to private (only owner has full control)
  acl = "private"
}

# Enable versioning on the S3 bucket
# This allows for recovery from accidental deletions and overwrites
resource "aws_s3_bucket_versioning" "artifacts_versioning" {
  bucket = aws_s3_bucket.artifacts.id
  
  versioning_configuration {
    # Enable versioning to keep multiple versions of an object
    status = "Enabled"
  }
}

# Configure server-side encryption for data at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts_encryption" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      # Use AES-256 encryption (server-side encryption with Amazon S3-managed keys)
      sse_algorithm = "AES256"
    }
  }
}

# Configure bucket ownership controls
# This ensures consistent behavior for new objects in the bucket
resource "aws_s3_bucket_ownership_controls" "artifacts_ownership" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    # Prefer the bucket owner for new objects
    # This is the recommended setting for most use cases
    object_ownership = "BucketOwnerPreferred"
  }
}

# Output the name of the created S3 bucket
# This can be referenced by other Terraform configurations
output "artifacts_bucket_name" {
  description = "The name of the S3 bucket used for artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

# Output the ARN of the S3 bucket
output "artifacts_bucket_arn" {
  description = "The ARN of the S3 bucket used for artifacts"
  value       = aws_s3_bucket.artifacts.arn
}
