job "nextcloud-backend" {
  datacenters = ["cascadia"]

  # Persistence
  group "db" {
    count = 1

    volume "nextcloud_db" {
      type      = "host"
      source    = "nextcloud_db"
    }

    network {
      port "db" { static = 3306 }
    }

    task "nextcloud-db" {
      driver = "docker"

      template {
        data = <<-EOF
          {{ with secret "kv/apps/nextcloud/mysql" }}
          MYSQL_ROOT_PASSWORD = "{{ .Data.data.root_password }}"
          MYSQL_PASSWORD = "{{ .Data.data.password }}"
          MYSQL_DATABASE = "{{ .Data.data.database }}"
          MYSQL_USER = "{{ .Data.data.username }}"
          {{ end }}
        EOF
        destination = "local/config.env"
        env = true
      }

      env {
        #MARIADB_AUTO_UPGRADE = "true"
      }

      config {
        image = "mariadb:10.6"
        image_pull_timeout = "15m"
        args = [
          "--transaction-isolation=READ-COMMITTED",
          "--log-bin=binlog",
          "--binlog-format=ROW",
        ]

        ports = ["db"]
        volumes = [
          "/mnt/nfs/nextcloud-db-dump:/dump",
        ]
      }

      volume_mount {
        volume      = "nextcloud_db"
        destination = "/var/lib/mysql"
      }

      resources {
        cpu = 1024
        memory = 1024
      }

      service {
        name = "nextcloud-db"
        port = "db"
      }

      vault {
        role = "nextcloud"
      }
      identity {
        name        = "vault_default"
        aud         = ["demophoon.com"]
        ttl         = "1h"
      }
    }
  }

  # Redis Cache
  group "cache" {
    count = 1
    network {
      port "redis" {
        static = 9736
        to = 6379
      }
    }
    task "redis" {
      driver = "docker"
      config {
        image = "redis"
        image_pull_timeout = "15m"
        ports = ["redis"]
      }
      resources {
        cpu = 1024
        memory = 512
      }
    }
    service {
      name = "nextcloud-redis"
      port = "redis"
      check {
        name     = "redis_probe"
        type     = "tcp"
        interval = "10s"
        timeout  = "1s"
      }
    }
  }

  group "image-processing" {
    count = 0
    network {
      port "imaginary" {
        to = 8088
      }
    }
    task "imaginary" {
      driver = "docker"
      config {
        image = "h2non/imaginary"
        ports = ["imaginary"]
      }
      env {
        PORT = "8088"
      }
      resources {
        cpu = 1024
        memory = 1024
      }
    }
    service {
      name = "nextcloud-imaginary"
      port = "imaginary"
      tags = [
        "internal=true",
      ]
    }
  }
}
