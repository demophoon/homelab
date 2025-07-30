variable "image_version" {
  type = string
  default = "v0.14.1"
}

job "jfs-controller" {
  datacenters = ["cascadia"]
  type = "system"

  group "controller" {
    task "plugin" {
      driver = "docker"

      config {
        image = "juicedata/juicefs-csi-driver:${var.image_version}"

        args = [
          "--endpoint=unix://csi/csi.sock",
          "--logtostderr",
          "--nodeid=test",
          "--v=5",
          "--by-process=true"
        ]

        privileged = true
      }

      csi_plugin {
        id        = "juicefs0"
        type      = "controller"
        mount_dir = "/csi"
      }
      resources {
        cpu    = 100
        memory = 512
      }
      env {
        POD_NAME = "csi-controller"
      }
    }
  }
}
