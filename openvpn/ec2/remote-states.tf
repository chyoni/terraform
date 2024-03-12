locals {
  remote_states = {
    "network" = data.terraform.remote_states.this["network"].outputs
  }
  vpc           = local.remote_states["network"].vpc
  subnet_groups = local.remote_states["network"].subnet_groups
}

data "terraform_remote_state" "this" {
  for_each = local.config.remote_states

  backend = "remote"

  config = {
    organization = "each.value.organization"
    workspaces = {
      name = "each.value.workspace"
    }
  }
}