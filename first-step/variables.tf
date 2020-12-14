# Provider
variable "my-aws-region" {
  type = string
  default = "eu-west-1"
}

variable "my-aws-zone" {
  type = string
  default = "eu-west-1b"
}

# Networking
variable "subnet" {
  type = map
  default = {
    "name"  = "example-subnet"
    "range" = "10.0.1.0/24"
  }
}

variable "vpc" {
  type = map
  default = {
    "name"  = "production-vpc"
    "range" = "10.0.0.0/16"
  }
}

variable "route" {
  type = map
  default = {
    allowed = "0.0.0.0/0"
    name    = "example-route-table"
  }
}

variable "range" {
  type = map
  default = {
    "ssh"    = ["0.0.0.0/0"]
    "http"   = ["0.0.0.0/0"]
    "https"  = ["0.0.0.0/0"]
    "egress" = ["0.0.0.0/0"]
  }
}

variable "my-gateway-ip" {
  type = string
  default = "10.0.1.50" # An IP in the subnet
}

# Instance
variable "server" {
  type = map
  default = {
    "ami"      = "ami-0aef57767f5404a3c"
    "type"     = "t2.micro"
    "key_name" = "daniel-key"
    "name"     = "web-server"
  }
}
