import warnings
from proxmoxer import ProxmoxAPI
from urllib3.exceptions import InsecureRequestWarning

# Filter out the specific warning
warnings.filterwarnings("ignore", category=InsecureRequestWarning)

# Proxmox VE API endpoint
API_URL = '192.168.10.10'

# Proxmox VE credentials
USERNAME = 'root@pam'
PASSWORD = 'Dolfijn3n759!'

def get_all_containers():
    """
    Get a list of all containers in Proxmox VE.
    """
    proxmox = ProxmoxAPI(API_URL, user=USERNAME, password=PASSWORD, verify_ssl=False)

    # Retrieve all containers
    lxc_containers = proxmox.nodes('pve').lxc.get()
    qemu_containers = proxmox.nodes('pve').qemu.get()
    
    vmids = []
    for container in lxc_containers:
        vmids.append(int(container['vmid']))

    for container in qemu_containers:
        vmids.append(int(container['vmid']))

    filtered_vmids = [vmid for vmid in vmids if not str(vmid).startswith('2')]
    sorted_vmids = sorted(filtered_vmids)

    return sorted_vmids

# Get the highest VMID from Proxmox VE nodes, excluding those starting with '2'.
def get_next_avaiable_ctid():
    proxmox = ProxmoxAPI(API_URL, user=USERNAME, password=PASSWORD, verify_ssl=False)

    # Retrieve all containers
    lxc_containers = proxmox.nodes('pve').lxc.get()
    qemu_containers = proxmox.nodes('pve').qemu.get()

    # Create a list to store the VMIDs
    vmids = []

    # Process LXC containers
    for container in lxc_containers:
        vmid = int(container['vmid'])
        if not str(vmid).startswith('2'):
            vmids.append(vmid)

    # Process QEMU containers
    for container in qemu_containers:
        vmid = int(container['vmid'])
        if not str(vmid).startswith('2'):
            vmids.append(vmid)

    # Return the highest VMID
    if vmids:
        return max(vmids)+1
    else:
        return None

# Usage example
highest_vmid = get_next_avaiable_ctid()

print(f'{highest_vmid}')