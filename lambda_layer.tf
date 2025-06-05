# This module creates a Lambda Layer containing the Python dependencies
# required by the scheduler Lambda functions.

# Local variable for the layer package path
locals {
  layer_package_path = "${path.module}/layer.zip"
}

# This null resource is responsible for executing the local build script
# to create the Lambda Layer package before the AWS resources are created.
resource "null_resource" "build_layer" {
  # The local-exec provisioner runs the build script when the resource is created
  provisioner "local-exec" {
    # Make the script executable and run it with error handling
    command = <<-EOT
      chmod +x ${path.module}/build_layer.sh && \
      if ! ${path.module}/build_layer.sh; then
        echo "Error: Failed to build the layer package"
        exit 1
      fi
      
      # Verify the layer package was created
      if [ ! -f "${local.layer_package_path}" ]; then
        echo "Error: Layer package not found at ${local.layer_package_path}"
        exit 1
      fi
    EOT
    
    # Set working directory to the module's directory
    working_dir = path.module
    
    # Set environment variables for the script
    environment = {
      LAYER_PACKAGE_PATH = local.layer_package_path
    }
  }

  # These triggers ensure the build script runs when either the requirements
  # or the build script itself changes. The filemd5 function generates a hash
  # of the file contents, causing the resource to be recreated when the hash changes.
  triggers = {
    # Trigger rebuild if requirements.txt changes
    requirements = filemd5("${path.module}/requirements.txt")
    # Trigger rebuild if build script changes
    script      = filemd5("${path.module}/build_layer.sh")
    # Include the Python version in the trigger
    python_version = "python3.9"
  }
  
  # Ensure the layer package is removed when the resource is destroyed
  lifecycle {
    create_before_destroy = true
  }
}

# Creates a new Lambda Layer version with the locally built package
resource "aws_lambda_layer_version" "scheduler_layer" {
  # Name of the Lambda Layer (must be unique within the region)
  layer_name = "scheduler-common"
  
  # Description of the layer's purpose
  description = "Common modules for AWS Scheduler Lambda functions"
  
  # Path to the local ZIP file containing the layer contents
  filename = local.layer_package_path
  
  # Lambda runtimes that can use this layer
  compatible_runtimes = ["python3.9"]
  
  # License information (optional but recommended)
  license_info = "MIT"
  
  # Ensure the build script runs before creating the layer
  depends_on = [null_resource.build_layer]
}

# Output the ARN of the created Lambda Layer
# This can be referenced by other Terraform configurations
output "lambda_layer_arn" {
  description = "The ARN of the scheduler Lambda layer"
  value       = aws_lambda_layer_version.scheduler_layer.arn
}

# Output the layer version number
output "lambda_layer_version" {
  description = "The version number of the Lambda layer"
  value       = aws_lambda_layer_version.scheduler_layer.version
}

# Output the created date of the layer version
output "lambda_layer_created_date" {
  description = "The date this version of the Lambda layer was created"
  value       = aws_lambda_layer_version.scheduler_layer.created_date
}

# Output the SHA256 hash of the layer content
output "layer_source_code_hash" {
  description = "Base64-encoded SHA256 hash of the layer package"
  value       = aws_lambda_layer_version.scheduler_layer.source_code_hash
}
