output "batch" {
  description = "The full batch account resource, including the (sensitive) primary and secondary access keys."
  value       = azurerm_batch_account.this["this"]
  sensitive   = true
}

output "applications" {
  description = "Map of batch applications keyed by their configuration key."
  value       = azurerm_batch_application.this
}

output "certificates" {
  description = "Map of batch certificates keyed by their configuration key (contains sensitive certificate data)."
  value       = azurerm_batch_certificate.this
  sensitive   = true
}

output "pools" {
  description = "Map of batch pools keyed by their configuration key (may contain sensitive credentials)."
  value       = azurerm_batch_pool.this
  sensitive   = true
}

output "jobs" {
  description = "Map of batch jobs keyed by '<pool>.<job>'."
  value       = azurerm_batch_job.this
}
