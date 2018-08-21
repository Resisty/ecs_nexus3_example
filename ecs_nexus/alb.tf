resource "aws_lb" "nexus_lb" {
  name                       = "${var.module_name}-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.nexus_lb_sg.id}"]
  subnets                    = ["${aws_subnet.nexus_subnets.*.id}"]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nexus_web" {
  name        = "${var.module_name}-web-tgtgrp"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.nexus_vpc.id}"
  stickiness  = {
    enabled = true
    type    = "lb_cookie"
  }
}

resource "aws_lb_listener" "nexus_web_443" {
  load_balancer_arn = "${aws_lb.nexus_lb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${aws_acm_certificate_validation.nexus_certificate_validation.certificate_arn}"
  default_action {
    target_group_arn = "${aws_lb_target_group.nexus_web.arn}"
    type             = "forward"
  }
}

resource "aws_lb" "nexus_privatelink_lb" {
  name                       = "${var.module_name}-privatelink-lb"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = ["${aws_subnet.nexus_subnets.*.id}"]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nexus_private_web" {
  name        = "${var.module_name}-priv-web-tgtgrp"
  port        = 8081
  protocol    = "TCP" # Network LBs don't support HTTP
  vpc_id      = "${aws_vpc.nexus_vpc.id}"
  stickiness  = [] # Terraform bug https://github.com/terraform-providers/terraform-provider-aws/issues/2746
}

resource "aws_lb_listener" "nexus_private_web_80" {
  load_balancer_arn = "${aws_lb.nexus_privatelink_lb.arn}"
  port              = "80"
  protocol          = "TCP" # Network LBs don't support HTTP
  default_action {
    target_group_arn = "${aws_lb_target_group.nexus_private_web.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "nexus_private_ssl" {
  name        = "${var.module_name}-priv-ssl-tgtgrp"
  port        = 8443
  protocol    = "TCP" # Network LBs don't support HTTP
  vpc_id      = "${aws_vpc.nexus_vpc.id}"
  stickiness  = [] # Terraform bug https://github.com/terraform-providers/terraform-provider-aws/issues/2746
}

resource "aws_lb_listener" "nexus_private_ssl_443" {
  load_balancer_arn = "${aws_lb.nexus_privatelink_lb.arn}"
  port              = "443"
  protocol          = "TCP" # Network LBs don't support HTTP
  default_action {
    target_group_arn = "${aws_lb_target_group.nexus_private_ssl.arn}"
    type             = "forward"
  }
}

