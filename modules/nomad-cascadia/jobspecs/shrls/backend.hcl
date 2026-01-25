job "shrls-backend" {
  datacenters = ["cascadia"]
  priority = 60
  constraint {
    attribute = "${meta.region}"
    value     = "cascadia"
  }

  group "mongodb" {
    count = 1
    network {
      port "db" { static = 27017 }
    }
    task "db" {
      driver = "docker"
      config {
        image = "mongo:5"
        ports = ["db"]
        volumes = [
          "/mnt/nfs/shrls/db:/data/db"
        ]
      }
      resources {
        cpu = 256
        memory = 1024
      }
    }

    service {
      name = "shrls-db"
      port = "db"
    }
  }
}
