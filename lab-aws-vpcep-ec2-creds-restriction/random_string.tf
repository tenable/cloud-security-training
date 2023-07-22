resource "random_string" "deploy_id" {
  length = 12
  special = false
  lower = true
  upper = false 
  numeric = true
}