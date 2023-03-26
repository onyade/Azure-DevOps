# Sample Name: Deploying a Ruby on Rails Web Application to Azure App Service with Ruby

# Import the Azure SDK for Ruby
require "azure_mgmt_resources"
require "azure_mgmt_network"
require "azure_mgmt_compute"
require "azure_mgmt_storage"
require "azure_mgmt_web"
require "ms_rest_azure"

# Authenticate to Azure using a service principal
client_id = "YOUR_CLIENT_ID"
client_secret = "YOUR_CLIENT_SECRET"
tenant_id = "YOUR_TENANT_ID"
subscription_id = "YOUR_SUBSCRIPTION_ID"
credentials = MsRestAzure::ApplicationTokenProvider.new(
  client_id,
  client_secret,
  tenant_id
)
resource_client = Azure::Resources::Profiles::Latest::Mgmt::Client.new(credentials)
resource_client.subscription_id = subscription_id
network_client = Azure::Network::Profiles::Latest::Mgmt::Client.new(credentials)
network_client.subscription_id = subscription_id
compute_client = Azure::Compute::Profiles::Latest::Mgmt::Client.new(credentials)
compute_client.subscription_id = subscription_id
storage_client = Azure::Storage::Profiles::Latest::Mgmt::Client.new(credentials)
storage_client.subscription_id = subscription_id
web_client = Azure::Web::Profiles::Latest::Mgmt::Client.new(credentials)
web_client.subscription_id = subscription_id

# Define the resource group that will contain the Azure resources
resource_group_name = "myresourcegroup"
location = "eastus"
resource_client.resource_groups.create_or_update(
  resource_group_name,
  {
    location: location
  }
)

# Define the virtual network and subnet that the VM will use
virtual_network_name = "myvirtualnetwork"
subnet_name = "mysubnet"
virtual_network_parameters = Azure::Network::Profiles::Latest::Mgmt::Models::VirtualNetwork.new.tap do |vnet|
  vnet.location = location
  vnet.address_space = Azure::Network::Profiles::Latest::Mgmt::Models::AddressSpace.new.tap do |address_space|
    address_space.address_prefixes = ["10.0.0.0/16"]
  end
  vnet.subnets = [
    Azure::Network::Profiles::Latest::Mgmt::Models::Subnet.new.tap do |subnet|
      subnet.name = subnet_name
      subnet.address_prefix = "10.0.0.0/24"
    end
  ]
end
network_client.virtual_networks.create_or_update(
  resource_group_name,
  virtual_network_name,
  virtual_network_parameters
)

# Define the virtual machine
vm_name = "myvm"
vm_parameters = Azure::Compute::Profiles::Latest::Mgmt::Models::VirtualMachine.new.tap do |vm|
  vm.location = location
  vm.os_profile = Azure::Compute::Profiles::Latest::Mgmt::Models::OSProfile.new.tap do |os_profile|
    os_profile.computer_name = vm_name
    os_profile.admin_username = "myadmin"
    os_profile.admin_password = "mypassword"
  end
  vm.hardware_profile = Azure::Compute::Profiles::Latest::Mgmt::Models::HardwareProfile.new.tap do |hardware_profile|
    hardware_profile.vm_size = "Standard_D2_v2"
  end
  vm.storage_profile = Azure::Compute::Profiles::Latest::Mgmt::Models::StorageProfile.new.tap do |storage_profile|
    storage_profile.image_reference = Azure::Compute::Profiles::Latest::Mgmt::Models::ImageReference.new.tap do |image_reference|
      image_reference.publisher = "Canonical"
      image_reference.offer = "UbuntuServer"
      image_reference.sku = "18.04-LTS"
      image_reference.version = "latest
