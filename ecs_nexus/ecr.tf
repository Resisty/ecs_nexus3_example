resource "aws_ecr_repository" "custom_nexus_image" {
  name = "${var.module_name}_custom_nexus_image"
}

resource "dockerimage_local" "custom_nexus_image" {
  dockerfile_path = "${path.module}/custom_nexus_image"
  registry        = "${aws_ecr_repository.custom_nexus_image.repository_url}:${var.nexus_repository_tag}"
}

resource "dockerimage_remote" "custom_nexus_image" {
  registry        = "${aws_ecr_repository.custom_nexus_image.repository_url}:${var.nexus_repository_tag}"
  image_id        = "${dockerimage_local.custom_nexus_image.id}"
}
