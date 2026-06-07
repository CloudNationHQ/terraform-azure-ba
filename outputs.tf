output "batch" {
  description = "contains all batch account config"
  value       = azurerm_batch_account.this
}

output "applications" {
  description = "contains all batch applications"
  value       = azurerm_batch_application.this
}

output "certificates" {
  description = "contains all batch certificates"
  value       = azurerm_batch_certificate.this
}

output "pools" {
  description = "contains all batch pools"
  value       = azurerm_batch_pool.this
}

output "jobs" {
  description = "contains all batch jobs"
  value       = azurerm_batch_job.this
}

output "private_endpoints" {
  description = "contains all private endpoints"
  value       = azurerm_private_endpoint.this
}
