output "id" {
  description = "ID of instance"
  value       = vultr_instance.web.id
}

output "ip" {
  description = "IPv4 address of instance"
  value       = vultr_instance.web.main_ip
}
