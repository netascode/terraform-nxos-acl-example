terraform {
  required_version = ">= 1.1.0"

  required_providers {
    nxos = {
      source  = "netascode/nxos"
      version = ">=0.3.21"
    }
  }
}

locals {
  inventory = yamldecode(file("data/inventory.yaml"))
  devices   = lookup(local.inventory, "switches", [])
  config    = yamldecode(file("data/config.yaml"))

  device_acls = { for pair in setproduct(local.devices, lookup(local.config, "acls", [])) : "${pair[0].name}.${pair[1].name}" => pair }

  device_acl_entries = { for e in flatten([
    for device in local.devices : [
      for acl in lookup(local.config, "acls", []) : [
        for entry in lookup(acl, "entries", []) : {
          key                       = "${device.name}.${acl.name}.${entry.seq}"
          device                    = device.name
          acl                       = acl.name
          sequence_number           = entry.seq
          action                    = lookup(entry, "action", null)
          protocol                  = lookup(entry, "protocol", null)
          source_prefix             = lookup(entry, "src_prefix", null)
          source_prefix_length      = lookup(entry, "src_prefix_length", null)
          source_port_1             = lookup(entry, "src_port", null)
          source_port_operator      = lookup(entry, "src_port", null) != null ? "eq" : null
          destination_prefix        = lookup(entry, "dst_prefix", null)
          destination_prefix_length = lookup(entry, "dst_prefix_length", null)
          destination_port_1        = lookup(entry, "dst_port", null)
          destination_port_operator = lookup(entry, "dst_port", null) != null ? "eq" : null
          logging                   = lookup(entry, "logging", false)
        }
      ]
    ]
  ]) : e.key => e }
}

provider "nxos" {
  devices = local.devices
}

resource "nxos_ipv4_access_list" "acl" {
  for_each = local.device_acls

  device = each.value[0].name
  name   = each.value[1].name
}

resource "nxos_ipv4_access_list_entry" "acl_entry" {
  for_each = local.device_acl_entries

  device                    = each.value.device
  name                      = each.value.acl
  sequence_number           = each.value.sequence_number
  action                    = each.value.action
  protocol                  = each.value.protocol
  source_prefix             = each.value.source_prefix
  source_prefix_length      = each.value.source_prefix_length
  source_port_1             = each.value.source_port_1
  source_port_operator      = each.value.source_port_operator
  destination_prefix        = each.value.destination_prefix
  destination_prefix_length = each.value.destination_prefix_length
  destination_port_1        = each.value.destination_port_1
  destination_port_operator = each.value.destination_port_operator
  logging                   = each.value.logging

  depends_on = [nxos_ipv4_access_list.acl]
}
