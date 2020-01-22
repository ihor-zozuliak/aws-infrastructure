variable "vpc-name" {
  description = "VPC name"
  type        = string
  default     = "my-VPC"
}
variable "vpc-cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.10.0.0/16"
}
# [0] - for public-A
# [1] - for private-A
# [2] - for database-A
variable "subnet-a-name" {
  description = "Subnet names in availability zone A"
  type        = list
  default = [
    "public-A",
    "private-A",
    "database-A"
  ]
}
# [0] - for NAT-gateway
variable "eip-name" {
  description = "List of elastic IP address names"
  type        = list
  default = [
    "NAT-gateway"
  ]
}
variable "igw-name" {
  description = "Internet gateway name"
  type        = string
  default     = "my-IGW"
}
variable "nat-name" {
  description = "NAT gateway name"
  type        = string
  default     = "my-NAT-GW"
}
variable "routetb-name" {
  description = "Route table names list"
  type        = list
  default = [
    "main",
    "public",
    "private",
    "database"
  ]
}
variable "all-ip" {
  description = "All IP addresses allowed"
  type        = string
  default     = "0.0.0.0/0"
}
