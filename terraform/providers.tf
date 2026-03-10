provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "eks"
  region = var.aws_region
}
