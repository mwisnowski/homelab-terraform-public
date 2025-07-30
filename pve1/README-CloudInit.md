# PVE1 Cloud-Init Configuration

## Generic Cloud-Init Setup Complete

### Files in this directory:

1. **Generic Cloud-Init Configuration**
   - `cloud-init/homelab-userdata.yml` - Generic cloud-init configuration for all VMs

2. **Terraform Files using cloud-init**:
   - `dnsserver.tf` - Secondary DNS server (ns2)
   - `jumpbox.tf` - Tailscale VPN gateway

### VMs Configured: 2 VMs

| VM Name | Service | IP Address | VMID | Purpose |
|---------|---------|------------|------|---------|
| ns2 | DNS | X.X.X.3 | 1003 | Secondary DNS server |
| jumpbox | VPN | X.X.X.40 | 1040 | Tailscale gateway |

### Cloud-Init Configuration Includes:
- **Timezone**: America/Los_Angeles (Pacific Time) 
- **Package Management**: Updates package database, installs essential tools
- **Standard Packages**: curl, wget, vim, htop, git, unzip, tree, net-tools, etc.
- **NTP Configuration**: Syncs with pool.ntp.org servers
- **SSH Configuration**: Maintains existing SSH settings from Terraform
- **Logging**: Logs setup completion to `/var/log/cloud-init-custom.log`

### Deployment Instructions:

1. **Copy cloud-init file to Proxmox server**:
   ```bash
   # On your Proxmox server (PVE1):
   sudo cp cloud-init/homelab-userdata.yml /var/lib/vz/snippets/
   sudo chown root:root /var/lib/vz/snippets/homelab-userdata.yml
   sudo chmod 644 /var/lib/vz/snippets/homelab-userdata.yml
   ```

2. **Enable cloud-init in Terraform files**:
   ```terraform
   # Uncomment this line in your .tf files:
   cicustom = "user=local:snippets/homelab-userdata.yml"
   ```

3. **Apply Terraform changes**:
   ```bash
   cd pve1/
   terraform plan -var-file="secrets.tfvars"   # Review changes
   terraform apply -var-file="secrets.tfvars"  # Apply changes
   ```

### Benefits:
- **Consistent timezone** across PVE1 VMs
- **Standardized package installation**
- **Proper time synchronization** 
- **Single configuration file** to maintain
- **Easy to modify** for future requirements
- **Reusable** across environments

### Troubleshooting:
- **File not found**: Ensure `homelab-userdata.yml` exists in `/var/lib/vz/snippets/` on PVE1
- **Permission issues**: Check file ownership and permissions
- **Cloud-init not running**: Verify the `cicustom` parameter is uncommented

### Next Steps:
- Copy the cloud-init file to your PVE1 Proxmox server
- Uncomment `cicustom` lines in terraform files if desired
- Run `terraform plan` to verify changes
- Apply changes with `terraform apply`