# Nexus Repository As An AWS ECS Service

This README is not intended as a full explanation of how this module works or
is implemented; that should be more or less obvious from the terraform
configuration files.

The contents of this README will serve as warnings and "gotchas" encountered in
building something like this.

## Caveats and Important Notes
---

1. You cannot spin up a high-availability cluster all at once; the clustering
   software is somewhat brittle in this regard. You _must_ create a cluster of
   one container and allow the service to come up first, _then_ you can
   re-deploy the ECS service with a larger size (3, 4, whatever your AZ count
   is, mostl likely). This will require successive runs of terraform, but you
   should be able to use the passed-in parameter `num_containers` to easily
   control it from the module invocation in `../main.tf`.

### Domain Registration and SSL

In order to request and validate the SSL certificate for the service, you must
first register a domain; see `variables.tf` and `acm.tf`. A variable
`route53_zone_name` is passed in as the name for which to request a certificate
and this name must be the registered domain.

Additionally: you may need to copy the 4 nameservers from Route53 for the
domain you're creating and have them entered into DNS as part of the request you
create with your registrar.

### Launch Configuration and Autoscaling Group Changes

The current implementation of Terraform does not support automatically updating
launch configurations; you must destroy the autoscaling group to which it is
attached, then the launch configuration itself, then re-apply with your
changes.

### Updating the Nexus container

1. Make any changes to the Dockerfile or entrypoint.sh script.
1. Check `../main.tf` for Nexus module instantiations and update the
   `nexus_repository_tag` value.
    1. OR
    1. *_and this is not the recommended path_*
    1. Alternatively, remove the above key from the module instantiation and
       instead update the default value in `variables.tf`.
