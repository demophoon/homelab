locals {
  memory_max = var.memory_max > 0 ? var.memory_max : var.memory * 2

  tags = concat(
    [
      "module=nomad-service",
    ],
    var.hostname == "" ? [] : [
      "traefik.enable=true",
      "traefik.http.routers.${var.name}.rule=host(`${var.hostname}`)",
    ],
    var.additional_tags
  )

  internal_tags = concat(
    [
      "module=nomad-service",
      "internal=true",
    ],
    var.additional_tags
  )

  external_services = [for service in var.services : {
    name = service.name
    port = service.port
    tags = concat(
      local.tags,
      service.tags
    )
  }]
  internal_services = [for service in var.services : {
    name = "${service.name}-internal"
    port = service.port
    tags = concat(
      local.internal_tags,
      service.tags
    )
  }]
  services = concat(local.external_services, local.internal_services)
}

data "nomad_job_parser" "default" {
  hcl = templatefile("${path.module}/template/base-service.hcl", {
    name = var.name,
    environment = var.environment,
    image = var.image,
    image_version = var.image_version,
    cpu = var.cpu,
    memory = var.memory,
    memory_max = local.memory_max,
    vault_role = var.vault_role,
    services = local.services
  })

  canonicalize = true
}

data "nomad_job_parser" "input_jobspec" {
  count = var.jobspec == null ? 0 : 1

  hcl = var.jobspec
  canonicalize = true
}

module "deepmerge" {
  source  = "Invicton-Labs/deepmerge/null"
  version = "0.1.6"

  maps = [for each in [
      jsondecode(data.nomad_job_parser.default.json),
      var.jobspec != null ? jsondecode(data.nomad_job_parser.input_jobspec[0].json) : null,
    ] : each if each != null
  ]
}

output "jobspec" {
  value = templatefile("${path.module}/template/base-service.hcl", {
    name = var.name,
    environment = var.environment,
    image = var.image,
    image_version = var.image_version,
    cpu = var.cpu,
    memory = var.memory,
    memory_max = local.memory_max,
    vault_role = var.vault_role,
    services = var.services
  })
}

resource "nomad_job" "job" {
  jobspec = jsonencode(module.deepmerge.merged)
  json = true
}
