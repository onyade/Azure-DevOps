package main

import (
    "context"
    "fmt"
    "github.com/Azure/azure-sdk-for-go/profiles/latest/compute/mgmt/compute"
    "github.com/Azure/azure-sdk-for-go/services/network/mgmt/2021-02-01/network"
    "github.com/Azure/go-autorest/autorest"
    "github.com/Azure/go-autorest/autorest/azure/auth"
    "log"
    "os"
)

func main() {
    // Define the authentication parameters
    tenantID := "YOUR_TENANT_ID"
    clientID := "YOUR_CLIENT_ID"
    clientSecret := "YOUR_CLIENT_SECRET"
    subscriptionID := "YOUR_SUBSCRIPTION_ID"
    authorizer, err := auth.NewAuthorizerFromEnvironment()
    if err != nil {
        log.Fatalf("Failed to create Azure authorizer: %v", err)
    }

    // Create a virtual network
    vnetClient := network.NewVirtualNetworksClient(subscriptionID)
    vnetClient.Authorizer = authorizer
    vnetName := "my-vnet"
    vnetLocation := "eastus"
    vnetParameters := network.VirtualNetwork{
        Location: &vnetLocation,
        VirtualNetworkPropertiesFormat: &network.VirtualNetworkPropertiesFormat{
            AddressSpace: &network.AddressSpace{
                AddressPrefixes: &[]string{"10.0.0.0/16"},
            },
            Subnets: &[]network.Subnet{
                {
                    Name: &"default",
                    SubnetPropertiesFormat: &network.SubnetPropertiesFormat{
                        AddressPrefix: &"10.0.0.0/24",
                    },
                },
            },
        },
    }
    vnetFuture, err := vnetClient.CreateOrUpdate(context.Background(), "my-resource-group", vnetName, vnetParameters)
    if err != nil {
        log.Fatalf("Failed to create virtual network: %v", err)
    }
    err = vnetFuture.WaitForCompletionRef(context.Background(), vnetClient.Client)
    if err != nil {
        log.Fatalf("Failed to create virtual network: %v", err)
    }
    log.Println("Virtual network created successfully.")

    // Create a network interface
    nicClient := network.NewInterfacesClient(subscriptionID)
    nicClient.Authorizer = authorizer
    nicName := "my-nic"
    nicLocation := "eastus"
    nicIPConfigName := "my-ipconfig"
    nicIPConfig := network.InterfaceIPConfiguration{
        Name: &nicIPConfigName,
        InterfaceIPConfigurationPropertiesFormat: &network.InterfaceIPConfigurationPropertiesFormat{
            PrivateIPAllocationMethod: network.Dynamic,
            Subnet: &network.Subnet{
                ID: &vnetFuture.Result().Subnets[0].ID,
            },
        },
    }
    nicParameters := network.Interface{
        Location: &nicLocation,
        InterfacePropertiesFormat: &network.InterfacePropertiesFormat{
            IPConfigurations: &[]network.InterfaceIPConfiguration{nicIPConfig},
        },
    }
    nicFuture, err := nicClient.CreateOrUpdate(context.Background(), "my-resource-group", nicName, nicParameters)
    if err != nil {
        log.Fatalf("Failed to create network interface: %v", err)
    }
    err = nicFuture.WaitForCompletionRef(context.Background(), nicClient.Client)
    if err != nil {
        log.Fatalf("Failed to create network interface: %v", err)
    }
    log.Println("Network interface created successfully.")

    // Create a virtual machine
    vmClient := compute.NewVirtualMachinesClient(subscriptionID)
   
