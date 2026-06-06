output "batch" {
  description = "contains all batch account configuration"
  value       = azurerm_batch_account.this
}

output "applications" {
  description = "contains all batch application configuration"
  value       = azurerm_batch_application.this
}

output "certificates" {
  description = "contains all batch certificate configuration"
  value       = azurerm_batch_certificate.this
}

output "pools" {
  description = "contains all batch pool configuration"
  value       = azurerm_batch_pool.this
}

output "jobs" {
  description = "contains all batch job configuration"
  value       = azurerm_batch_job.this
}
