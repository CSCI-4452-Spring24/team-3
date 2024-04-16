provider "aws" {
    shared_config_files = ["./../.aws/config.txt"] 
    # change the value of the profile
    profile = "iker-dev"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}