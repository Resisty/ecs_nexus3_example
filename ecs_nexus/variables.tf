data "aws_caller_identity" "current" {}

variable "module_name" {
  default = "nexus-repository"
}

variable "aws_region" {
  default = "us-west-2"
}

variable "ecs_ami_map" {
  type = "map"
  default = {
    us-west-1      = "ami-9ad4dcfa"
    us-west-2      = "ami-1d668865"
    us-east-1      = "ami-a7a242da"
    us-east-2      = "ami-b86a5ddd"
    eu-west-1      = "ami-0693ed7f"
    eu-west-2      = "ami-f4e20693"
    eu-west-3      = "ami-698b3d14"
    eu-central-1   = "ami-698b3d14"
    ap-northeast-1 = "ami-68ef940e"
    ap-northeast-2 = "ami-a5dd70cb"
    ap-southeast-1 = "ami-0a622c76"
    ca-central-1   = "ami-5ac94e3e"
    ap-south-1     = "ami-2e461a41"
    sa-east-1      = "ami-d44008b8"
  }
}

variable "ecs_instance_type" {
  default = "t2.medium"
}

variable "nexus_repository_tag" {
  default = "3_13"
}

# See ../variables.yaml
# Redefined here just in case
variable "allowed_cidrs" {
  type = "list"
  default = ["0.0.0.0/0"]
}

variable "route53_zone_id" {}
variable "route53_zone_name" {}
variable "nexus_vpc_cidr" {
  default = "172.16.0.0/24"
}

variable "az_map" {
  type = "list"
  default = [
    { az          = "us-west-2a",
      subnet_cidr = "172.16.0.0/26"
    },
    { az          = "us-west-2b",
      subnet_cidr = "172.16.0.64/26"
    },
    { az          = "us-west-2c",
      subnet_cidr = "172.16.0.128/26"
    }
  ]
}

variable "num_azs" {
  default = 3
}

# This is currently 1 because we have not purchased high availability
# We can only run one at a time
# TODO: Remove this comment if/when we get the @#$%@#$@#$% thing running HA
variable "num_running_containers" {
  default = 0
}

variable "efs_mountpoint" {
  default = "/mnt/efs"
}

variable "efs_nexus_storage" {
  default = "/nexus"
}

variable "efs_sonatype_work" {
  default = "/sonatype-work"
}

variable "nexus_hostport" {
  default = 8081
}

variable "nexus_containerport" {
  default = 8081
}

variable "nexus_hostsslport" {
  default = 8443
}

variable "nexus_containersslport" {
  default = 8443
}

variable "sensu_vpc_id" {
  default = "vpc-aaaaaaaa"
}

variable "sensu_vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "sensu_sg_id" {
  default = "sg-bbbbbbbb"
}

variable "nexus_privatelink_principals" {
  type = "list"
  default = [
    "arn:aws:iam::123456789100:user/allowed-user"
  ]
}

variable "kms_key_arn" {}
