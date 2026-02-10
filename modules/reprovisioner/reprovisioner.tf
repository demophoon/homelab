resource "random_integer" "day_of_month" {
  min = 1
  max = 28
  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    listener_arn = var.workspace
  }
}

resource "nomad_job" "reprovision" {
  jobspec = templatefile("${path.module}/templates/reprovision.nomad.hcl", {
    workspace    = var.workspace
    day_of_month = random_integer.day_of_month.result
  })
}
