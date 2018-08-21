resource "aws_ecs_cluster" "nexus_repository_cluster" {
  name = "${var.module_name}-cluster"
}

locals {
  full_image_string = "${aws_ecr_repository.custom_nexus_image.registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.custom_nexus_image.name}:${var.nexus_repository_tag}"
  container_name    = "${var.module_name}-RunNexusRepositoryDev"
}

data "template_file" "nexus_repository_hazelcast_port_mappings_fragment" {
  count = "${var.num_running_containers}"
  template = "${file("${path.module}/templates/nexus_repository_hazelcast_port_mappings_fragment.json")}"
  vars {
    portnum = "${format("%d", 5701 + count.index)}"
  }
}

data "template_file" "nexus_repository_json_document" {
  template = "${file("${path.module}/templates/nexus_repository.json")}"
  vars {
    image            = "${jsonencode(local.full_image_string)}"
    container_name   = "${jsonencode(local.container_name)}"
    aws_region       = "${jsonencode(var.aws_region)}"
    hostport         = "${var.nexus_hostport}"
    containerport    = "${var.nexus_containerport}"
    hostsslport      = "${var.nexus_hostsslport}"
    containersslport = "${var.nexus_containersslport}"
    hazelcast_ports  = "${join("\n", data.template_file.nexus_repository_hazelcast_port_mappings_fragment.*.rendered)}"
    awslogs_group    = "${jsonencode(data.template_file.nexus_repository_loggroupname.rendered)}"
  }
}

resource "aws_ecs_task_definition" "nexus_repository" {
  family                = "${var.module_name}"
  container_definitions = "${data.template_file.nexus_repository_json_document.rendered}"
  task_role_arn         = "${aws_iam_role.nexus_repository_ecs_execute_role.arn}"
  execution_role_arn    = "${aws_iam_role.nexus_repository_ecs_execute_role.arn}"
  network_mode          = "host"
  volume {
    name      = "efs-storage"
    host_path = "${var.efs_mountpoint}${var.efs_nexus_storage}"
  }
  volume {
    name      = "efs-work"
    host_path = "${var.efs_sonatype_work}"
  }
}

resource "aws_ecs_service" "nexus_repository_service" {
  name                               = "${var.module_name}-service"
  cluster                            = "${aws_ecs_cluster.nexus_repository_cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.nexus_repository.arn}"
  desired_count                      = "${var.num_running_containers}"
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 600
  iam_role                           = "${aws_iam_role.nexus_repository_ecs_execute_role.arn}"
  depends_on                         = [
    "aws_iam_role_policy.nexus_repository_ecs_execution_policy",
    "aws_lb_listener.nexus_web_443"
  ]
  load_balancer                      = {
    target_group_arn = "${aws_lb_target_group.nexus_web.arn}"
    container_name   = "${local.container_name}"
    container_port   = "${var.nexus_containerport}"
  }
}

resource "aws_appautoscaling_target" "nexus_ecs_target" {
  max_capacity       = "${var.num_running_containers}"
  min_capacity       = "${var.num_running_containers}"
  resource_id        = "service/${aws_ecs_cluster.nexus_repository_cluster.name}/${aws_ecs_service.nexus_repository_service.name}"
  role_arn           = "${aws_iam_role.nexus_repository_ecs_execute_role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
