variable "image_version" {
  type = string
  default = "0.2.1"
}

job "shrls-demo" {
  datacenters = ["cascadia"]
  priority = 60
  type = "batch"

  periodic {
    cron = "0 * * * *"
    prohibit_overlap = true
  }

  group "shrls" {
    count = 1

    network {
      port "app" { to = 8000 }
    }

    service {
      name = "shrls-demo"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.shrls-demo.rule=host(`shrls-demo.brittg.com`)",
      ]
      port = "app"
    }
    task "app" {
      driver = "docker"

      env {
	SHRLS_EXPERIMENTAL = "true"
      }

      config {
	image = "ghcr.io/demophoon/shrls:${var.image_version}"
	ports = ["app"]
	args = [
	  "serve",
	  "--demo",
	  "--config",
	  "/local/config.yaml",
	]
      }

      resources {
	cpu = 256
	memory = 100
      }

      template {
	destination = "local/config.yaml"
	data = <<EOF
host: shrls-demo.brittg.com
port: 8000
resolve_urls_matching_hosts:
  - shrls-demo.brittg.com
remove_query_parameters_matching_hosts:
  - shrls-demo.brittg.com
default_redirect: /admin
default_redirect_ssl: true
default_terminal_string: |
  You've reached the curl redirect!
EOF
      }
    }
  }
}
