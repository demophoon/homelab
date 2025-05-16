<div align="center">

# Homelab

My [Terraform](https://developer.hashicorp.com/terraform/intro) configurations for managing VMs in [Proxmox](https://www.proxmox.com/en/), container workloads
in [Nomad](https://developer.hashicorp.com/nomad/intro), and all of the supporting services found below.
</div>

---

## Overview

In order to achieve a resilient and immutable home lab, I use a number of
Infrastructure as Code tools so everything is intentional and repeatable.

One of the self-imposed challenges that I set forth for my homelab was that I
didn't want any machine to risk staying around so long as to invite major
system drift that fell outside of this repository. For this reason the VMs that
are created expire after 30 days and must be recreated from scratch. This
forces me to place the changes that I care about within this repo instead of
applying them piecemeal to each individual VM.

This homelab also has a unique quality in that if I need to perform any
maintenance on any of the servers at home, workloads can be setup to float
between servers at home and any cloud provider thanks to Nomad. This can also
be utilized to add additional capacity if it is ever needed.

## The Setup

This homelab uses Proxmox as the primary hypervisor at home and Digitalocean as
a VPS provider within the cloud. When Terraform spins up a new VM, it creates a
custom Cloud-init image for each VM which is seeded with the configuration it
needs to:

  - Install any dependant packages, certificates, and configurations.
  - Connect to my [Tailscale](https://tailscale.com/kb) tailnet
  - Configure [Keepalived](https://www.keepalived.org/) for LAN load balancing between home servers
  - Automatically discover other [Consul](https://developer.hashicorp.com/consul/docs/intro) servers running on the tailnet to join
  - Retrieve the rest of the provisioner secrets placed in [Vault](https://developer.hashicorp.com/vault/docs/about-vault/what-is-vault) by Terraform, listed below.
    - TLS certificates for internal services to be running on the nodes
    - Vault tokens for Nomad
    - Signed SSH host certificates
  - Connect persistent storage from NAS (On home nodes only)
  - Start Vault and Nomad in the overall cluster

Once Nomad has connected it automatically starts receiving jobs from the leader
and system services like [Traefik](https://doc.traefik.io/traefik/) spin up with certificates stored in Vault.
Traefik being up also makes the node eligible to start receiving traffic within Keepalived.

So far terraform is run manually on my laptop but this is something that I'm
hoping to solve as this project becomes more public and automated.

## Core Components and Supporting Services

  - [Proxmox VE](https://www.proxmox.com/en/): KVM Hypervisor
  - [Terraform](https://developer.hashicorp.com/terraform/intro): Infrastructure as Code tool
  - [TrueNAS](https://www.truenas.com/): Persistent network storage
  - [Tailscale](https://tailscale.com/): Flat mesh networking
  - [Consul](https://developer.hashicorp.com/consul/docs/intro): Service discovery and distributed KV store
  - [Vault](https://developer.hashicorp.com/vault/docs/about-vault/what-is-vault): Secrets management service
  - [Nomad](https://developer.hashicorp.com/nomad/intro): Container and workload scheduler
  - [Let's Encrypt](https://letsencrypt.org/): Certificate Authority providing TLS for all for free
  - [Keepalived](https://www.keepalived.org/): Layer 4 load balancing and failover routing between servers
  - [Traefik](https://doc.traefik.io/traefik/): Application proxy

## Repo Structure

```shell
.
├── docs                # Documentation
│
├── modules             # Terraform modules
│   ├── cloudinit         # Cloud-init provisioning scripts and helpers
│   ├── digitalocean      # DigitalOcean VM Provisioner (Uses cloudinit)
│   ├── proxmox_vm        # Proxmox VM Provisioner (Uses cloudinit)
│   ├── nomad             # Configure and run Nomad jobs with Terraform
│   │   └── jobspecs        # Raw nomad job templates
│   └── vault             # Vault backends, roles, and policies
│
└── workspaces          # Terraform workspaces
    ├── prod-home         # DNS, Nomad, and other home cluster glue
    ├── digitalocean      # DNS, Nomad, and other DigitalOcean cluster glue
    ├── proxmox           # Primary VM on Beryllium hypervisor
    ├── proxmox-aux       # Secondary VM on Beryllium hypervisor
    ├── nuc               # Primary VM on Nuc hypervisor
    ├── nuc-aux           # Secondary VM on Nuc hypervisor
    ├── sol               # Primary VM on Sol hypervisor
    └── sol-aux           # Secondary VM on Sol hypervisor

```


## Hardware

| Name      | Device                  | CPU                    | RAM       | Primary Storage         | Purpose             |
| --------- | ----------------------- | ---------------------- | --------- | ----------------------- | ------------------- |
| Beryllium | Home built workstation  | 12-Core Ryzen 9 3900x  | 64GB DDR4 | 1TB NVMe SSD            | Proxmox Hypervisor  |
| Nuc       | Coffee Lake Intel NUC   | 4-Core Intel i5-8259U  | 32GB DDR4 | 1TB SATA SSD            | Proxmox Hypervisor  |
| Sol       | Dell Optiplex 3050 USFF | 4-Core Intel i5-7500T  | 16GB DDR4 | 256GB NVMe SSD          | Proxmox Hypervisor  |
| Cube      | ZimaCube Creator Pack   | 10-Core Intel i5-1235U | 64GB DDR5 | 4x4TB SATA SSD (RAIDZ2) | TrueNAS ZFS Storage |

## Roadmap

- [ ] Provision VMs via Cloud-init + Ansible
- [ ] Automated Terraform deployments via CI/CD
- [ ] Use a tool like [Renovate](https://www.mend.io/renovate/) to automate container and package upgrades
