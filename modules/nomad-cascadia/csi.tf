resource "nomad_job" "jfs-controller" {
  jobspec = file("${path.module}/csi/juicefs/controller.hcl")
  hcl2 {
    vars = {
      image_version = var.juicefs_version
    }
  }
}

resource "nomad_job" "jfs-node" {
  jobspec = file("${path.module}/csi/juicefs/node.hcl")
  hcl2 {
    vars = {
      image_version = var.juicefs_version
    }
  }
}

resource "nomad_job" "jfs-metadata" {
  jobspec = file("${path.module}/csi/juicefs/metadata.hcl")
}
