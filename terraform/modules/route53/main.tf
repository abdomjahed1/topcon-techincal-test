resource "aws_route53_zone" "public_zone" {
  name = var.domain_name

  tags = {
    Environment = "dev"
    Project     = "prueba-it"
  }
}
