job "nexus" {
  datacenters = ["cascadia"]
  priority = 80

  group "nexus" {
    count = 1

    network {
      port "app" { to = 8081 }
    }

    volume "persistance" {
      type            = "host"
      source          = "proxmox"
    }

    task "registry" {
      driver = "docker"

      volume_mount {
        volume      = "persistance"
        destination = "/vh"
      }

      env {
        # Add any necessary environment variables here
        INSTALL4J_ADD_VM_PARAMS = "-Xms512M -Xmx512M -XX:MaxDirectMemorySize=512M"
      }

      config {
        image = "sonatype/nexus3"
        ports = ["app"]
        volumes = [
          "/mnt/proxmox/nexus/data:/nexus-data",
        ]
      }

      resources {
        cpu = 256
        memory = 512
        memory_max = 1024
      }

      service {
        name = "nexus"
        tags = [
          "traefik.enable=true",
          "internal=true",
        ]
        port = "app"
      }
    }
  }
}
