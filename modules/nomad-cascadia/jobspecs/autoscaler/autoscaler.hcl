variable "image_version" {
  type = string
  default = "0.3.5"
}

job "autoscaler" {
  datacenters = ["cascadia"]

  group "autoscaler" {
    count = 1

    task "autoscaler" {
      driver = "docker"

      config {
        image   = "hashicorp/nomad-autoscaler:${var.image_version}"
        command = "nomad-autoscaler"
        args    = ["agent", "-config", "${NOMAD_TASK_DIR}/config.hcl"]
      }

      template {
        data = <<EOF
plugin_dir = "/plugins"

nomad {
  address = "https://{{env "attr.unique.network.ip-address" }}:4646"
  skip_verify = true
}
apm "nomad" {
  driver = "nomad-apm"
  config  = {
    address = "https://{{env "attr.unique.network.ip-address" }}:4646"
    skip_verify = true
  }
}

strategy "target-value" {
  driver = "target-value"
}
          EOF

        destination = "${NOMAD_TASK_DIR}/config.hcl"
      }
    }
  }
}

