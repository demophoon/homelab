resource "consul_acl_auth_method" "nomad-jwt" {
  name          = "nomad-workloads"
  type          = "jwt"
  max_token_ttl = "5m"

  config_json = jsonencode({
    JWKSURL = "https://nomad.service.consul.demophoon.com:4646/.well-known/jwks.json"
  })
}
