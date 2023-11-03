terraform {
  source = "../../../infrastructure-modules/tags"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  application = include.env.locals.cluster_name
  environment = include.env.locals.environment
  repository  = include.env.locals.repository
}
