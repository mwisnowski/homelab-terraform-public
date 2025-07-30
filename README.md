# Homelab Terraform Infrastructure

This repository contains Terraform configurations for deploying a complete homelab infrastructure on Proxmox Virtual Environment (PVE).

## Overview

This Terraform infrastructure automatically provisions and manages virtual machines for a comprehensive homelab environment including:
- **DevOps Tools**: Gitea Git repository
- **Infrastructure**: DNS servers, monitoring stack
- **Management**: Ansible control host and Tailscale VPN
- **Web Services**: Reverse proxy and web applications

## Architecture

### Infrastructure Layout

The infrastructure is split across two Proxmox nodes:

#### PVE1 Node (`pve1/`)
- **DNS**: Secondary DNS server (ns2)
- **VPN Gateway**: Tailscale jumpbox for remote access

#### PVE2 Node (`pve2/`)
- **Management**: Ansible control host
- **DNS**: Primary DNS server (ns1)
- **Git Services**: Gitea lightweight Git platform
- **Monitoring**: Prometheus/Grafana stack
- **Web Platform**: Nginx reverse proxy and web applications

### Virtual Machine Inventory

| Node | VM Name | Service | IP Address | VMID | Resources | Storage | Purpose |
|------|---------|---------|------------|------|-----------|---------|---------|
| **PVE1** | ns2 | DNS | X.X.X.3 | 1003 | 1C/2GB | 15GB | Secondary DNS server |
| **PVE1** | jumpbox | VPN | X.X.X.40 | 1040 | 1C/2GB | 10GB | Tailscale gateway |
| **PVE2** | ns1 | DNS | X.X.X.2 | 1002 | 1C/2GB | 15GB | Primary DNS server |
| **PVE2** | ansible-host | Management | X.X.X.20 | 1020 | 1C/2GB | 50GB | Ansible control node |
| **PVE2** | gitea | Git | X.X.X.30 | 1030 | 2C×2S/4GB | 100GB | Gitea Git platform |
| **PVE2** | monitor | Monitoring | X.X.X.11 | 1011 | 2C/4GB | 40GB | Prometheus/Grafana |
| **PVE2** | web-server | Web Apps | X.X.X.15 | 1015 | 2C/8GB | 50GB | Web services & proxy |

**Total Resources**: 7 VMs across 2 nodes - 11 vCPUs (13 sockets), 27GB RAM, 280GB Storage

### Core Infrastructure
- **Template**: `ubuntu-noble-cloud-init-template` (Ubuntu 24.04 LTS)
- **Network**: `X.X.X.0/24` subnet
- **Gateway**: `X.X.X.1`
- **DNS**: `X.X.X.2` (primary), `X.X.X.3` (secondary)
- **Domain**: `example.com`
- **Storage**: Proxmox Local-LVM storage

## File Structure

```
homelab-terraform-public/
├── README.md                    # This documentation
├── homelab-terraform            # Legacy/symlink directory
├── pve1/                        # Proxmox Node 1 configurations
│   ├── README-CloudInit.md      # Cloud-init documentation
│   ├── cloud-init/
│   │   └── homelab-userdata.yml # VM initialization template
│   ├── dnsserver.tf            # Secondary DNS (ns2)
│   ├── jumpbox.tf              # Tailscale VPN gateway
│   ├── main.tf                 # Provider and base configuration
│   └── vars.tf                 # Variable definitions
└── pve2/                       # Proxmox Node 2 configurations
    ├── README-CloudInit.md     # Cloud-init documentation
    ├── cloud-init/
    │   └── homelab-userdata.yml # VM initialization template
    ├── ansible-host.tf         # Ansible control node
    ├── dnsserver.tf            # Primary DNS (ns1)
    ├── git.tf                  # Gitea services
    ├── main.tf                 # Provider and base configuration
    ├── monitoring.tf           # Prometheus/Grafana stack
    ├── vars.tf                 # Variable definitions
    └── webserver.tf            # Web services and reverse proxy
```

## Quick Start

### Prerequisites
- Terraform >= 1.0
- Access to Proxmox VE cluster
- Ubuntu cloud-init template configured
- Proxmox API credentials

### Deployment

1. **Configure Proxmox credentials**:
   ```bash
   # Create secrets file for each node
   cp secrets.tfvars.example pve1/secrets.tfvars
   cp secrets.tfvars.example pve2/secrets.tfvars
   # Edit with your Proxmox details
   ```

2. **Deploy PVE1 infrastructure**:
   ```bash
   cd pve1/
   terraform init
   terraform plan -var-file="secrets.tfvars"
   terraform apply -var-file="secrets.tfvars"
   ```

3. **Deploy PVE2 infrastructure**:
   ```bash
   cd ../pve2/
   terraform init
   terraform plan -var-file="secrets.tfvars"
   terraform apply -var-file="secrets.tfvars"
   ```

### Variables Configuration

Create `secrets.tfvars` in each directory with:
```hcl
# Proxmox connection
pm_api_url      = "https://X.X.X.X:8006/api2/json"
pm_user         = "your-user@pam"
pm_password     = "your-password"

# VM configuration
username        = "your-username"
password        = "your-password"
ssh_keys        = "your-ssh-public-key"

# Network configuration
proxmox_host    = "pve1"  # or "pve2" for respective node
```

## Cloud-Init Configuration

Each VM is automatically configured using cloud-init which handles:
- User account creation
- SSH key deployment
- Package installation
- Network configuration
- Security hardening

See `README-CloudInit.md` in each directory for detailed cloud-init documentation.

## Security

- **Sensitive files** are excluded via `.gitignore`
- **API credentials** stored in `secrets.tfvars` (not tracked)
- **SSH keys** and certificates managed via cloud-init
- **State files** contain sensitive data - keep secure

## Management

### Terraform State
Each Proxmox node maintains separate state:
- `pve1/terraform.tfstate` - Node 1 resources (ns2, jumpbox)
- `pve2/terraform.tfstate` - Node 2 resources (ns1, ansible-host, gitea, monitor, web-server)

### Post-Deployment
After Terraform deployment, use the companion Ansible repository for:
- Service configuration
- Container deployment
- Monitoring setup
- SSL certificate management

## Troubleshooting

### Common Issues
- **Template not found**: Ensure `ubuntu-noble-cloud-init-template` exists on both nodes
- **Network conflicts**: Verify IP ranges don't overlap
- **API access**: Check Proxmox user permissions
- **VMID conflicts**: Ensure VMIDs are unique across cluster

### Useful Commands
```bash
# Check Terraform state
terraform show

# Plan changes
terraform plan -var-file="secrets.tfvars"

# Destroy infrastructure (careful!)
terraform destroy -var-file="secrets.tfvars"
```

## Related Projects

This Terraform infrastructure works alongside:
- **homelab-ansible**: Post-deployment configuration and service management

---

> **Note**: This is a public repository. All sensitive information (IPs, credentials, domains) has been sanitized.
> Configure your actual values in `secrets.tfvars` files.