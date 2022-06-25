# Cisco Nexus 9000 ACL Terraform Example

This example demonstrates how the [NX-OS Terraform Provider](https://registry.terraform.io/providers/netascode/nxos/latest/docs) can be used to maintain ACLs on one or more Nexus 9000 switches.

The configuration is derived from a set of yaml files in the `data` [directory](https://github.com/netascode/terraform-nxos-acl-example/tree/main/data).

To point this to your own Nexus 9000 switches, update the `data/inventory.yaml` file accordingly.

```yaml
---
switches:
  - name: SWITCH-1
    url: https://10.1.1.1
  - name: SWITCH-2
    url: https://10.1.1.2
```

Credentials can either be provided via environment variables:

```shell
export NXOS_USERNAME=admin
export NXOS_PASSWORD=Cisco123
```

Or by updating the provider configuration in `main.tf`:

```terraform
provider "nxos" {
  username = admin
  password = Cisco123
  devices  = local.devices
}
```
