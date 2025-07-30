variable "image_version" {
  type = string
  default = "0.2.1"
}
variable "image_url" {
  type = string
  default = null
}

job "shrls-app" {
  datacenters = ["cascadia"]
  priority = 60

  group "shrls" {
    scaling {
      enabled = true
      min     = 1
      max     = 3

      policy {
	check {
	  source = "nomad-apm"
	  query  = "avg_cpu"

	  strategy "threshold" {
	    upper_bound = 100
	    lower_bound = 70
	    delta       = 1
	  }
	}

	check {
	  source = "nomad-apm"
	  query  = "avg_memory"

	  strategy "threshold" {
	    upper_bound = 100
	    lower_bound = 70
	    delta       = 1
	  }
	}
      }

    }

    network {
      port "app" { to = 8000 }
    }

    service {
      name = "shrls"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.shrls.rule=host(`brittg.com`)",
      ]
      port = "app"
    }

    task "app" {
      driver = "docker"

      config {
        image = var.image_url != null ? var.image_url : "ghcr.io/demophoon/shrls:${var.image_version}"
	ports = ["app"]
	volumes = [
	  "/mnt/nfs/shrls/uploads:/uploads"
	]
	args = [
	  "serve",
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
host: brittg.com
port: 8000
state:
  mongodb:
    connection_string: mongodb://{{- with secret "mongodb/creds/shrls-rw" }}{{ .Data.username }}:{{ .Data.password }}{{- end }}@{{- range service "shrls-db" }}{{ .Address }}:{{ .Port }}{{- end }}/shrls
uploads:
  directory:
    path: /uploads
auth:
  basic:
    {{- with secret "kv/apps/shrls/app" }}
    username: {{ .Data.data.username }}
    password: {{ .Data.data.password }}
    {{- end }}
resolve_urls_matching_hosts:
  - vm.tiktok.com
  - www.tiktok.com
remove_query_parameters_matching_hosts:
  - vm.tiktok.com
  - www.tiktok.com
default_redirect: https://www.brittg.com/
default_redirect_ssl: true
default_terminal_string: |
  ---
  name: Britt Gresham
  title: Senior Software Engineer
  contact:
    email: sayhi@brittg.com
    website: https://www.brittg.com
    github: https://github.com/demophoon
    linkedin: https://linkedin.com/in/bgresham
    gpg_fingerprint: 5D1199736DD75CE96D8995CB083B3535EC5E3ABA
  skills:
    languages:
      - python
      - golang
      - puppet
      - javascript
      - html5
    technology:
      - eks/gcp
      - docker
      - hashistack
      - infrastructure as code
      - git
      - ci/cd


  #         :@@@@@@@@@@@@+                Welcome to Britt's Website!
  #     =%%%%@@@@@@@@@@@@%%%%%
  #     +@@@@@@@@@@@@@@@@@@@@@
  # +***%@@@@@@@@@@@@@@@@@@@@@****.       Github: @demophoon
  # #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:       Email me at sayhi@brittg.com
  # #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:
  # #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@:       Resume at https://brittg.com/resume
  # #@@@@@@@@@@@@*************++++.
  # #@@@@@@@@@@@@-------------
  # +###@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+
  #     +@@@#----@@-----@@----@@-----@@
  #     =%%%*----+@@@@@@@+----+@@@@@@@+     If you would like to visit this on
  #          -----------------            your phone, curl then scan the code at
  #          -----------------                https://brittg.com/homepage.qr
  #          ----+++++++++
  #          ----+++++++++
  #     =###*------------=####            +------------------------------------+
  #     +@@@#============*@@@@            |                                    |
  # =***#@@@%####++++*###%@@@@****.       |  Britt Gresham --- Terminal Nerd   |
  # #@@@@@@@#==@@++++#@*=*@@@@@@@@:       |                                    |
  # #@@@@@#+===@@++++#@*==++@@@@@@:       +------------------------------------+
EOF
  }

      vault {
	role = "shrls"
      }
    }
  }
}
