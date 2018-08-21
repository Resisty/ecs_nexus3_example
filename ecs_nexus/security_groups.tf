data "aws_security_group" "sensu_sg" {
  id = "${var.sensu_sg_id}"
}

resource "aws_security_group" "nexus_lb_sg" {
  name        = "${var.module_name}-lb-sg"
  description = "Security group for nexus lb for ${var.module_name}"
  vpc_id      = "${aws_vpc.nexus_vpc.id}"

  # SSH access from Elemental Colo
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidrs}"
  }

  # HTTPS from Elemental Colo and Amazon SEA+PDX networks
  # obtained from MANSE
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidrs}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nexus_efs_sg" {
  name        = "${var.module_name}-efs-sg"
  description = "Security group for nexus EFS for ${var.module_name}"
  vpc_id      = "${aws_vpc.nexus_vpc.id}"

  # NFS access from EC2 security groups
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["${aws_vpc.nexus_vpc.cidr_block}"]
    security_groups = ["${aws_security_group.nexus_instance_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nexus_instance_sg" {
  name        = "${var.module_name}-instance-sg"
  description = "Security group for nexus instance for ${var.module_name}"
  vpc_id      = "${aws_vpc.nexus_vpc.id}"

  # Allow instances to talk to each other
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # HTTP access from Load Balancer security groups
  ingress {
    from_port       = 8081
    to_port         = 8081
    protocol        = "tcp"
    security_groups = ["${aws_security_group.nexus_lb_sg.id}", "${data.aws_security_group.sensu_sg.id}"]
    cidr_blocks     = ["${aws_vpc.nexus_vpc.cidr_block}"] # The NLB for PrivateLink has a private IP which is practically impossible to obtain
                                                          # automatically, so we need to allow the whole VPC. Yay.
  }

  # HTTPS access from Network Load Balancer
  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    cidr_blocks     = ["${aws_vpc.nexus_vpc.cidr_block}"] # The NLB for PrivateLink has a private IP which is practically impossible to obtain
                                                          # automatically, so we need to allow the whole VPC. Yay.
  }

  # SSH from Elemental Colo and Amazon SEA+PDX networks
  # obtained from MANSE
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidrs}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = ["aws_vpc_peering_connection.sensu_vpc_peering_cnxn", "aws_route_table.sensu_to_nexus_route"]
}
