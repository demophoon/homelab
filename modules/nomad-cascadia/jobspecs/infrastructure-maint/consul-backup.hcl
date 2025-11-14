job "infrastructure-maintenance-consul" {
  datacenters = ["cascadia"]

  type = "batch"

  periodic {
    cron             = "0 0 */2 * * * *"
    prohibit_overlap = true
  }

  group "consul-backup" {
    count = 1

    restart {
      attempts = 0
    }

    volume "consul-snapshots" {
      type   = "host"
      source = "consul-snapshots"
    }

    task "backup" {
      driver = "exec"

      volume_mount {
        volume      = "consul-snapshots"
        destination = "/snapshots"
        read_only = false
      }

      config {
        command = "sh"
        args = [
          "-c",
          "consul snapshot save /snapshots/consul-backup.$(date +%s).snap",
        ]
      }
    }
  }
}
