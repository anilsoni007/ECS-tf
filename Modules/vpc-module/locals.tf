locals {
  common_tags = {
    "Environment" = var.environment
    "Owner"       = var.Owner
    "DataType"    = var.environment == "sandbox" ? "internal" : "PHI"
    "CreatedBy"   = "terraform"
  }
}