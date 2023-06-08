# Import packages
import warnings
from proxmoxer import ProxmoxAPI
from urllib3.exceptions import InsecureRequestWarning

"""
Global Variables
"""
proxmox = None
node = None


# Filter out the specific warning
warnings.filterwarnings("ignore", category=InsecureRequestWarning)

"""
Functions
"""
# Set up the connection with the Proxmox VE API
def set_proxmox_connection(url="192.168.10.10", username="root@pam", password="Dolfijn3n759!"):
    global proxmox
    proxmox = ProxmoxAPI(url, user=username, password=password, verify_ssl=False)

# Get the next available CT ID
def get_next_available_id(node):

    # Retrieve all containers
    lxc_containers = proxmox.nodes('{node}').lxc.get()
    qemu_containers = proxmox.nodes('{node}').qemu.get()

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

    # Return the next available VMID
    if vmids:
        return max(vmids)+1
    else:
        return None
    
# Get the OS template from Proxmox based on the OS and Version
def get_ostemplate(os, version):
    # Check if proxmox has a established connection
    if not proxmox:
        print("Error: Proxmox connection not established. Please call set_proxmox_connection() fisrt.")
        return None
    
    # Get the 'pve' cluster
    cluster = proxmox.nodes('pve')

    # Retrieve all templates
    templates = cluster.storage.local.content.get()

    for template in templates:
        if os in template['volid'] and version in template['volid']:
            return template['volid']
        
    return None

# Create a new LXC container in Proxmox
def create_container(node, hostname, password, ctid, ostemplate, disk_size, cpu_cores, memory, network, storage='local', vlan=None):
    # Check if proxmox has established connection
    if not proxmox:
        print("Error: Proxmox connection no established. Please call set_proxmox_connection() first.")
        return
    
    # Get the 'pve' cluster
    cluster = proxmox.nodes('pve')

    # Create the LXC Container
    container = cluster.lxc.create(
        vmid=ctid,
        ostemplate=ostemplate,
        hostname=hostname,
        storage=storage,
        disk=disk_size,
        cores=cpu_cores,
        memory=memory,
        net0=network
    )

# Usage example
set_proxmox_connection()
os_template = get_ostemplate('ubuntu', '22')

if os_template:
    print(f"Found OS template: {os_template}")
else:
    print("OS template not found.")