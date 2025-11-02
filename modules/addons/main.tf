terraform {
  required_providers {
    helm = { source = "hashicorp/helm", version = "~> 2.13" }
  }
}

variable "addons" {
  description = "Flexible map of addon definitions"
  type        = any
}

locals { names = toset(keys(var.addons)) }

resource "helm_release" "addon" {
  for_each         = local.names

  name             = replace(each.value, "_", "-")
  repository       = var.addons[each.value].repo
  chart            = var.addons[each.value].chart
  version          = try(var.addons[each.value].version, null)
  namespace        = var.addons[each.value].namespace
  create_namespace = true

  values = [ yamlencode(try(var.addons[each.value].values, {})) ]

  atomic          = true
  cleanup_on_fail = true
}
