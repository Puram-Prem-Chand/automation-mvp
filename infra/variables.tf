variable "aws_region" {
  type    = string
  default = "eu-west-2" # change if you prefer
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "terraform-deploy-key"
}

variable "public_key" {
  type        = string
  description = "The contents of your ~/.ssh/terraform_key.pub (pass via TF_VAR_public_key or -var)"
}