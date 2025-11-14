resource "nomad_node_pool" "nas" {
  name        = "nas"
  description = "Nodes on the NAS which store data."
}
