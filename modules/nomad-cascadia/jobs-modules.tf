module "it-tools" {
  source = "../../modules/nomad-service"

  name = "it-tools"
  image = "ghcr.io/sharevb/it-tools"
  image_version = "2026.1.4" # image: ghcr.io/sharevb/it-tools

  memory = 32
  cpu = 50

  hostname = "tools.brittg.com"

  enable_monitoring = true

  services = [
    {
      name = "app"
      port = 8080
      tags = []
    }
  ]
}

