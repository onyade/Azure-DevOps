# Sample Name: Provisioning and Configuring a Virtual Machine with Python in Azure

# Import the Azure SDK for Python
from azure.identity import AzureCliCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.storage import StorageManagementClient

# Authenticate to Azure using the Azure CLI
credential = AzureCliCredential()

# Define the resource group that will contain the Azure resources
resource_group_name = "myresourcegroup"
location = "eastus"
resource_client = ResourceManagementClient(credential, subscription_id)
resource_client.resource_groups.create_or_update(
    resource_group_name, {'location': location})

# Define the virtual network and subnet that the VM will use
network_client = NetworkManagementClient(credential, subscription_id)
virtual_network_name = "myvirtualnetwork"
subnet_name = "mysubnet"
poller = network_client.virtual_networks.create_or_update(
    resource_group_name, virtual_network_name,
    {
        "location": location,
        "address_space": {
            "address_prefixes": ["10.0.0.0/16"]
        }
    }
)
virtual_network_result = poller.result()
subnet_result = network_client.subnets.create_or_update(
    resource_group_name,
    virtual_network_name,
    subnet_name,
    {"address_prefix": "10.0.0.0/24"}
)

# Define the virtual machine
compute_client = ComputeManagementClient(credential, subscription_id)
vm_name = "myvm"
vm_parameters = {
    "location": location,
    "hardware_profile": {
        "vm_size": "Standard_D2_v2"
    },
    "storage_profile": {
        "image_reference": {
            "publisher": "Canonical",
            "offer": "UbuntuServer",
            "sku": "18.04-LTS",
            "version": "latest"
        }
    },
    "os_profile": {
        "computer_name": vm_name,
        "admin_username": "myadmin",
        "admin_password": "mypassword"
    },
    "network_profile": {
        "network_interfaces": [{
            "id": network_client.network_interfaces.get(
                resource_group_name,
                f"{vm_name}-nic"
            ).id
        }]
    }
}
poller = compute_client.virtual_machines.create_or_update(
    resource_group_name, vm_name, vm_parameters)
vm_result = poller.result()
