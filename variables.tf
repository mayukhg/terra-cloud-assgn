variable "name" {
  default     = "mg-test-vpc"
  type        = string
  description = "my-vpc-01"
}

variable "project" {
  default     = "my-first-prj"
  type        = string
  description = "my-prj-01"
}

variable "environment" {
  default     = "mg-test-env"
  type        = string
  description = "Name of environment this VPC is targeting"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "key_name" {
  default     = "mac-keypair"
  type        = string
  description = "EC2 Key pair name for the bastion"
}

variable "ami" {
  default = "ami-1a962263"
}

variable "s3bucket" {
  default = "mybucket"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks_1" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "public_subnet_cidr_blocks_2" {
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list
  description = "List of availability zones"
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
  #  validation {
  #    condition     = can(regex("[^t2]", var.instance-type))
  #    error_message = "Instance type cannot be anything other than t2 or t3 type and also not t3a.micro."
  #  }
}


/*
variable "bastion_ami" {
  type        = string
  description = "Bastion Amazon Machine Image (AMI) ID"
}

variable "bastion_ebs_optimized" {
  default     = false
  type        = bool
  description = "If true, the bastion instance will be EBS-optimized"
}

variable "bastion_instance_type" {
  default     = "t3.nano"
  type        = string
  description = "Instance type for bastion instance"
}
*/

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}
