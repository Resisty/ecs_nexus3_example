# Running Nexus 3 on AWS ECS

This is a non-functioning replica of a working configuration for deploying
Sonatype's Nexus 3 docker container on an AWS ECS cluster in high availability
(requires license purchased from Sonatype).

There are a _lot_ of prerequisites which are not addressed within the
configuration files present. I will try to enumerate them here.

## Prerequisites

* S3 backend
    * This isn't an actual prerequisite, but something to be aware of. Check
      `remote_config.tf`; you will need to create your bucket first before you
      can save TF state.
* Route53 zone and NS records
    * Work with your registrar to set these up first and expose the zone as a
      variable (see `ecs_nexus` module in `main.tf`)
* Docker image builder/pusher plugin
    *  To use this plugin, you'll have to build it w/: ``` $ go build
       github.com/zongoose/terraform-provider-docker-image ``` then add the
       following to your ~/.terraformrc file: ``` providers { dockerimage =
       "/path/to/terraform-provider-docker-image" } ```
* KMS keys
    * In my case these are pre-provisioned and referenced as variables in the
      module for decrypting sensitive values such as the license contents.
* VPC cidr space
    * Make sure you have a VPC set up with sufficient address space to spin up
      multiple instances to run your containers. See `cidr_blocks` in the
      `ecs_nexus` module declaration in `main.tf`.

## Notes

Some configs will reference network allowances for Sensu; I've left them in for
completeness as the origin of this example requires Sensu checks to run against
Nexus instances to validate uptime, throughput, HA, and other external metrics.
