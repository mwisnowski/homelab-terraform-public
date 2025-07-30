resource "proxmox_vm_qemu" "ns2" {
	count 	= 	1
	name	=	"ns2"
	desc 	=	"DNS Server VM using Cloud-Init"
	
	target_node = var.proxmox_host
	
	clone	=	"ubuntu-noble-cloud-init-template"
	vmid  = 1003
	full_clone = true

	agent	=	1

	# vm_state =	"stopped"
	os_type	=	"cloud-init"
	cores	=	1
	sockets	=	1
	memory	=	2048
	scsihw	=	"virtio-scsi-pci"
	bootdisk	=	"scsi0"

	disks {
    ide{
    	ide0{
    		cloudinit{
    			storage="local-lvm"
        		}
      		}
    	}

    scsi{
		scsi0{
        	disk{
			storage		=	"local-lvm"
			size		=	"15G"
			replicate	=	true
			discard		=	true
				}
			}	
		}
	}

	network {
		model	=	"virtio"
		bridge	=	"vmbr0"
		id	=	0
	}

	boot 	=	"order=scsi0"

	ipconfig0 = "ip=X.X.X.3/24,gw=X.X.X.1"
	nameserver = "X.X.X.2 X.X.X.3 8.8.8.8 8.8.4.4"
	searchdomain = "example.com"

	lifecycle {
	  ignore_changes = [network]
	}

	serial {
		id = 0
		type = "socket"
	}
	
	ciuser = var.username
	cipassword = var.password
	sshkeys = <<EOF
	${var.ssh_keys}
	EOF
	
	# Generic cloud-init configuration
	#cicustom = "user=local:snippets/homelab-userdata.yml"
}