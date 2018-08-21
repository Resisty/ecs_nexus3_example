variable "aws_region" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "elasticsearch_domain_name" {}
variable "elasticsearch_version" {}
variable "elasticsearch_instance_type" {}
variable "elasticsearch_instance_count" {}
variable "elasticsearch_ebs_type" {}
variable "elasticsearch_ebs_size" {}
variable "seti_logs_metrics_alarms_sub_arn" {}
variable "route53_zone" {}
variable "allowed_cidrs" {
  type = "list"
}
