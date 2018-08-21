data "aws_caller_identity" "current" {}
# BEFORE COPYING/INSTANTIATING THIS MODULE:
# READ THE MODULE'S README
# ./ecs_nexus/README.md
module "ecs_nexus" {
  source                 = "./ecs_nexus"
  kms_key_arn            = "${aws_kms_key.paddlefish_lambda_env_key.arn}"
  nexus_repository_tag   = "v3_13_0"
  route53_zone_id        = "${aws_route53_zone.route53_zone.zone_id}"
  route53_zone_name      = "${var.route53_zone}"
  nexus_vpc_cidr         = "172.16.0.0/24"
  num_azs                = 3
  num_running_containers = 3
  allowed_cidrs          = "${var.allowed_cidrs}"
  az_map                 = [
    { 
      az          = "us-west-2a"
      subnet_cidr = "172.16.0.0/26"
    },
    { 
      az          = "us-west-2b"
      subnet_cidr = "172.16.0.64/26"
    },
    { az          = "us-west-2c",
      subnet_cidr = "172.16.0.128/26"
    }
  ]
}
