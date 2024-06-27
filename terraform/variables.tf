variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "public_key" {
  description = "The public key for SSH access"
  type        = string
}

variable "private_key" {
  description = "The private key for SSH access"
  type        = string
}