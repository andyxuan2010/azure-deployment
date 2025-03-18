output "privateip" {
  value = azurerm_network_interface.this.private_ip_address
}

# Output Public IP (if provisioned)
output "public_ip" {
  value = var.public_network_enabled ? azurerm_public_ip.this[0].ip_address : "No Public IP Assigned"
}