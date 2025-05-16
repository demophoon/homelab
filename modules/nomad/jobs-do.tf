resource "nomad_job" "traefik_digitalocean" {
  provider = nomad.digitalocean
  jobspec = file("${path.module}/jobspecs/traefik/traefik-do.hcl")
  hcl2 {
    vars = {
      image_version = var.traefik_version
      region = "digitalocean"
    }
  }
}

resource "nomad_job" "tools" {
  provider = nomad.digitalocean
  jobspec = file("${path.module}/jobspecs/tools/tools.hcl")
}

resource "nomad_job" "devlog-do" {
  provider = nomad.digitalocean
  jobspec = file("${path.module}/jobspecs/devlog/blog.hcl")
  hcl2 {
    vars = {
      region = "digitalocean"
    }
  }
}

resource "nomad_job" "resume-do" {
  provider = nomad.digitalocean
  jobspec = file("${path.module}/jobspecs/resume/resume.hcl")
  hcl2 {
    vars = {
      image_version = var.resume_version
      region = "digitalocean"
    }
  }
}
