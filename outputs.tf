output "batch" {
  description = "contains all batch account configuration"
  value       = azurerm_batch_account.this
  sensitive   = true
}

output "applications" {
  description = "contains all batch application configuration"
  value       = azurerm_batch_application.this
}

output "certificates" {
  description = "contains all batch certificate configuration"
  value       = azurerm_batch_certificate.this
  sensitive   = true
}

output "pools" {
  description = "contains all batch pool configuration"
  value       = azurerm_batch_pool.this
  sensitive   = true
}

output "jobs" {
  description = "contains all batch job configuration"
  value       = azurerm_batch_job.this
}
