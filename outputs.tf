output "batch" {
  description = "contains all batch account configuration"
  value       = azurerm_batch_account.this
  sensitive   = true
}

output "applications" {
  description = "contains all batch applications"
  value       = azurerm_batch_application.this
}

output "certificates" {
  description = "contains all batch certificates"
  value       = azurerm_batch_certificate.this
  sensitive   = true
}

output "pools" {
  description = "contains all batch pools"
  value       = azurerm_batch_pool.this
  sensitive   = true
}

output "jobs" {
  description = "contains all batch jobs"
  value       = azurerm_batch_job.this
}

output "private_endpoints" {
  description = "contains all private endpoints"
  value       = azurerm_private_endpoint.this
}

output "diagnostic_settings" {
  description = "contains all diagnostic settings"
  value       = azurerm_monitor_diagnostic_setting.this
}

output "primary_access_key" {
  description = "the primary access key of the batch account"
  value       = azurerm_batch_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "the secondary access key of the batch account"
  value       = azurerm_batch_account.this.secondary_access_key
  sensitive   = true
}
