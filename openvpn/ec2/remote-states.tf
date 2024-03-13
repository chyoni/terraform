locals {
  remote_states = {
    "network" = data.terraform_remote_state.this["network"].outputs
  }
  vpc           = local.remote_states["network"].vpc
  subnet_groups = local.remote_states["network"].subnet_groups
}

data "terraform_remote_state" "this" {
  for_each = local.config.remote_states //config.yaml 파일의 remote_states를 가르킴

  backend = "remote"

  config = {
    organization = each.value.organization
    workspaces = {
      name = each.value.workspace
    }
  }
}
