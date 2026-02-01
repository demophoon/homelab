resource "nomad_job" "traefik_global" {
  jobspec = file("${path.module}/jobspecs/traefik/traefik.hcl")
  hcl2 {
    vars = {
      image_version = var.traefik_version
    }
  }
}

resource "nomad_job" "certbot" {
  jobspec = file("${path.module}/jobspecs/certbot/certbot.hcl")
}

# Home Assistant
resource "nomad_job" "homeassistant-app" {
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
  jobspec = file("${path.module}/jobspecs/homeassistant/homeassistant-backend.hcl")
}

resource "nomad_job" "registry" {
  jobspec = file("${path.module}/jobspecs/registry/registry.hcl")
}
resource "nomad_job" "nexus" {
  jobspec = file("${path.module}/jobspecs/nexus/registry.hcl")
}

resource "nomad_job" "minio" {
  jobspec = file("${path.module}/jobspecs/minio/minio.hcl")
}

resource "nomad_job" "vaultwarden" {
  jobspec = file("${path.module}/jobspecs/vaultwarden/vaultwarden.hcl")
  hcl2 {
    vars = {
      image_version = var.vaultwarden_version
    }
  }
}

resource "nomad_job" "immich-backend" {
  jobspec = file("${path.module}/jobspecs/immich/backend.hcl")
}

resource "nomad_job" "immich-ml" {
  jobspec = file("${path.module}/jobspecs/immich/ml.hcl")
  hcl2 {
    vars = {
      image_version = var.immich_version
    }
  }
}

resource "nomad_job" "immich-app" {
  jobspec = file("${path.module}/jobspecs/immich/app.hcl")
  hcl2 {
    vars = {
      image_version = var.immich_version
    }
  }
}

resource "nomad_job" "shrls-backend" {
  jobspec = file("${path.module}/jobspecs/shrls/backend.hcl")
}

resource "nomad_job" "shrls-app" {
  jobspec = file("${path.module}/jobspecs/shrls/app.hcl")
  hcl2 {
    vars = {
      image_version = var.shrls_version
    }
  }
}

resource "nomad_job" "shrls-demo" {
  jobspec = file("${path.module}/jobspecs/shrls/demo.hcl")
  hcl2 {
    vars = {
      image_version = var.shrls_version
    }
  }
}

resource "nomad_job" "syncthing" {
  jobspec = file("${path.module}/jobspecs/syncthing/syncthing.hcl")
  hcl2 {
    vars = {
      image_version = var.syncthing_version
    }
  }
}


resource "nomad_job" "devlog" {
  jobspec = file("${path.module}/jobspecs/devlog/blog.hcl")
  hcl2 {
    vars = {
      region = "global"
    }
  }
}

resource "nomad_job" "resume" {
  jobspec = file("${path.module}/jobspecs/resume/resume.hcl")
  hcl2 {
    vars = {
      image_version = var.resume_version
      region = "global"
    }
  }
}

resource "nomad_job" "bluesky-pds" {
  jobspec = file("${path.module}/jobspecs/bluesky-pds/app.hcl")
  hcl2 {
    vars = {
      image_version = "0.4"
    }
  }
}

resource "nomad_job" "podgrab" {
  jobspec = file("${path.module}/jobspecs/podgrab/podgrab.hcl")
  hcl2 {
    vars = {
    }
  }
}

resource "nomad_job" "authentik_backend" {
  jobspec = file("${path.module}/jobspecs/authentik/backend.hcl")
}

resource "nomad_job" "authentik_app" {
  jobspec = file("${path.module}/jobspecs/authentik/app.hcl")
  hcl2 {
    vars = {
      image_version = var.authentik_version
    }
  }
}
resource "nomad_job" "changedetection" {
  jobspec = file("${path.module}/jobspecs/changedetection/app.hcl")
}

resource "nomad_job" "static" {
  jobspec = file("${path.module}/jobspecs/static/static.hcl")
}

resource "nomad_job" "transmission" {
  jobspec = file("${path.module}/jobspecs/transmission/transmission.hcl")
}
resource "nomad_job" "nzbget" {
  jobspec = file("${path.module}/jobspecs/nzbget/nzbget.hcl")
}
resource "nomad_job" "arrs" {
  jobspec = file("${path.module}/jobspecs/arr/apps.hcl")
}
resource "nomad_job" "bliss" {
  jobspec = file("${path.module}/jobspecs/bliss/app.hcl")
}
resource "nomad_job" "jellyfin" {
  jobspec = file("${path.module}/jobspecs/jellyfin/jellyfin.hcl")
}

resource "nomad_job" "valheim" {
  jobspec = file("${path.module}/jobspecs/valheim/valheim.nomad.hcl")
}

resource "nomad_job" "factorio" {
  jobspec = file("${path.module}/jobspecs/factorio/factorio.nomad.hcl")
}

resource "nomad_job" "minecraft" {
  jobspec = file("${path.module}/jobspecs/minecraft/minecraft.nomad.hcl")
}

resource "nomad_job" "paperless-ngx" {
  jobspec = file("${path.module}/jobspecs/paperless-ngx/app.hcl")
}
resource "nomad_job" "paperless-ngx-db" {
  jobspec = file("${path.module}/jobspecs/paperless-ngx/backend.hcl")
}

resource "nomad_job" "postgres-nas" {
  jobspec = file("${path.module}/jobspecs/postgres/postgres.hcl")
}
resource "nomad_job" "linkwarden" {
  jobspec = file("${path.module}/jobspecs/linkwarden/linkwarden.hcl")
}

resource "nomad_job" "mariadb-nas" {
  jobspec = file("${path.module}/jobspecs/mariadb/mariadb.hcl")
}
resource "nomad_job" "booklore" {
  jobspec = file("${path.module}/jobspecs/booklore/booklore.hcl")
}

resource "nomad_job" "donetick" {
  jobspec = file("${path.module}/jobspecs/donetick/donetick.hcl")
}

resource "nomad_job" "koffan" {
  jobspec = file("${path.module}/jobspecs/koffan/koffan.hcl")
}

resource "nomad_job" "technitium" {
  jobspec = file("${path.module}/jobspecs/technitium/technitium.hcl")
}

resource "nomad_job" "ittools" {
  jobspec = file("${path.module}/jobspecs/ittools/ittools.hcl")
}

resource "nomad_job" "forgejo" {
  jobspec = file("${path.module}/jobspecs/forgejo/forgejo.hcl")
}

resource "nomad_job" "miniflux" {
  jobspec = file("${path.module}/jobspecs/miniflux/miniflux.hcl")
}

resource "nomad_job" "uptimekuma" {
  jobspec = file("${path.module}/jobspecs/uptimekuma/uptimekuma.hcl")
}

resource "nomad_job" "nextcloud-backend" {
  jobspec = file("${path.module}/jobspecs/nextcloud/backend.hcl")
}
resource "nomad_job" "nextcloud-app" {
  jobspec = file("${path.module}/jobspecs/nextcloud/app.hcl")
}

resource "nomad_job" "vikunja" {
  jobspec = file("${path.module}/jobspecs/vikunja/vikunja.hcl")
}

resource "nomad_job" "memos" {
  jobspec = file("${path.module}/jobspecs/memos/memos.hcl")
}
