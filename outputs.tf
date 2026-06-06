output "batch" {
  description = "contains all batch account config"
  sensitive   = true
  value       = azurerm_batch_account.this
}

output "applications" {
  description = "contains all batch applications"
  value       = azurerm_batch_application.this
}

output "certificates" {
  description = "contains all batch certificates"
  sensitive   = true
  value       = azurerm_batch_certificate.this
}

output "pools" {
  description = "contains all batch pools"
  sensitive   = true
  value       = azurerm_batch_pool.this
}

output "jobs" {
  description = "contains all batch jobs"
  value       = azurerm_batch_job.this
}
