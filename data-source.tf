# Define Terraform data source:
data "aws_availability_zones" "available" {
  state = "available"
}
