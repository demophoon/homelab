resource "nomad_job" "traefik_global" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/traefik/traefik.hcl")
  hcl2 {
    vars = {
      image_version = var.traefik_version
      region = "global"
    }
  }
}

resource "nomad_job" "certbot" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/certbot/certbot.hcl")
}

# Home Assistant
resource "nomad_job" "homeassistant-app" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/homeassistant/homeassistant.hcl")
  hcl2 {
    vars = {
      ha_version = var.homeassistant_version
      ha_image = var.homeassistant_image // Overrides ha_version
      zigbee2mqtt_version = var.zigbee2mqtt_version
    }
  }
}
resource "nomad_job" "homeassistant-backend" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/homeassistant/homeassistant-backend.hcl")
}
resource "nomad_job" "homeassistant-music-assistant" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/homeassistant/homeassistant-music.hcl")
}

resource "nomad_job" "registry-cache" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/registry-cache/cache.hcl")
}

resource "nomad_job" "registry" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/registry/registry.hcl")
}

resource "nomad_job" "minio" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/minio/minio.hcl")
}

resource "nomad_job" "vaultwarden" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/vaultwarden/vaultwarden.hcl")
  hcl2 {
    vars = {
      image_version = var.vaultwarden_version
    }
  }
}

resource "nomad_job" "nextcloud-backend" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/nextcloud/backend.hcl")
}

resource "nomad_job" "nextcloud-app" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/nextcloud/app.hcl")
  hcl2 {
    vars = {
      image_version = var.nextcloud_version
    }
  }
}

resource "nomad_job" "immich-power-tools" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/immich/power-tools.hcl")
}

resource "nomad_job" "immich-backend" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/immich/backend.hcl")
}

resource "nomad_job" "immich-ml" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/immich/ml.hcl")
  hcl2 {
    vars = {
      image_version = var.immich_version
    }
  }
}

resource "nomad_job" "immich-app" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/immich/app.hcl")
  hcl2 {
    vars = {
      image_version = var.immich_version
    }
  }
}

resource "nomad_job" "shrls-backend" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/shrls/backend.hcl")
}

resource "nomad_job" "shrls-app" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/shrls/app.hcl")
  hcl2 {
    vars = {
      image_version = var.shrls_version
    }
  }
}

resource "nomad_job" "shrls-demo" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/shrls/demo.hcl")
  hcl2 {
    vars = {
      image_version = var.shrls_version
    }
  }
}

resource "nomad_job" "actualbudget" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/actualbudget/app.hcl")
}

#resource "nomad_job" "factorio" {
#  provider = nomad.global
#  jobspec = file("${path.module}/jobspecs/factorio/factorio.hcl")
#  hcl2 {
#    vars = {
#      image_version = var.factorio_version
#    }
#  }
#}

resource "nomad_job" "autoscaler" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/autoscaler/autoscaler.hcl")
  hcl2 {
    vars = {
      image_version = var.autoscaler_version
    }
  }
}

resource "nomad_job" "pleroma-backend" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/pleroma/backend.hcl")
}
resource "nomad_job" "pleroma-app" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/pleroma/app.hcl")
}

resource "nomad_job" "syncthing" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/syncthing/syncthing.hcl")
  hcl2 {
    vars = {
      image_version = var.syncthing_version
    }
  }
}

resource "nomad_job" "vikunja" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/vikunja/vikunja.hcl")
  hcl2 {
    vars = {
      image_version = var.vikunja_version
    }
  }
}

resource "nomad_job" "devlog" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/devlog/blog.hcl")
  hcl2 {
    vars = {
      region = "global"
    }
  }
}

resource "nomad_job" "resume" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/resume/resume.hcl")
  hcl2 {
    vars = {
      image_version = var.resume_version
      region = "global"
    }
  }
}

resource "nomad_job" "bluesky-pds" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/bluesky-pds/app.hcl")
  hcl2 {
    vars = {
      image_version = "0.4"
    }
  }
}

resource "nomad_job" "podgrab" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/podgrab/podgrab.hcl")
  hcl2 {
    vars = {
    }
  }
}

resource "nomad_job" "authentik_backend" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/authentik/backend.hcl")
}

resource "nomad_job" "authentik_app" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/authentik/app.hcl")
  hcl2 {
    vars = {
      image_version = var.authentik_version
    }
  }
}

resource "nomad_job" "paperless-ngx" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/paperless-ngx/app.hcl")
}

resource "nomad_job" "openwebui" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/openwebui/app.hcl")
}

resource "nomad_job" "memos" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/memos/app.hcl")
}

resource "nomad_job" "changedetection" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/changedetection/app.hcl")
}

resource "nomad_job" "lgtm" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/lgtm/app.hcl")
}

#resource "nomad_job" "miniflux-db" {
#  provider = nomad.global
#  jobspec = file("${path.module}/jobspecs/miniflux/backend.hcl")
#}

#resource "nomad_job" "miniflux-app" {
#  provider = nomad.global
#  jobspec = file("${path.module}/jobspecs/miniflux/app.hcl")
#}

resource "nomad_job" "calibre" {
  provider = nomad.global
  jobspec = file("${path.module}/jobspecs/calibre/calibre.hcl")
  hcl2 {
    vars = {
      image_version = var.calibre_version
    }
  }
}
