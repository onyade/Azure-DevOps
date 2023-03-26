// Sample Name: Deploying a Node.js Web Application to Azure App Service with Node.js

// Import the Azure SDK for Node.js
const msRestNodeAuth = require("@azure/ms-rest-nodeauth");
const { WebSiteManagementClient } = require("@azure/arm-appservice");
const { Site } = require("@azure/arm-appservice");

// Authenticate to Azure using a service principal
const clientId = "YOUR_CLIENT_ID";
const tenantId = "YOUR_TENANT_ID";
const clientSecret = "YOUR_CLIENT_SECRET";
const subscriptionId = "YOUR_SUBSCRIPTION_ID";
const credentials = await msRestNodeAuth.loginWithServicePrincipalSecret(
    clientId,
    clientSecret,
    tenantId
);
const webSiteManagementClient = new WebSiteManagementClient(credentials, subscriptionId);

// Define the resource group that will contain the Azure resources
const resourceGroupName = "myresourcegroup";

// Define the Azure App Service plan
const appServicePlanName = "myappserviceplan";
await webSiteManagementClient.appServicePlans.createOrUpdate(
    resourceGroupName,
    appServicePlanName,
    {
        location: "westus",
        sku: { name: "B1", capacity: 1 }
    }
);

// Define the Azure App Service
const appServiceName = "myappservice";
await webSiteManagementClient.webApps.createOrUpdate(
    resourceGroupName,
    appServiceName,
    {
        serverFarmId: `/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Web/serverfarms/${appServicePlanName}`,
        siteConfig: {
            appSettings: [
                {
                    name: "WEBSITE_RUN_FROM_PACKAGE",
                    value: "https://github.com/myusername/myapp/archive/main.zip"
                }
            ],
            linuxFxVersion: "NODE|12-lts"
        }
    }
);

// Start the Azure App Service
const appService = await webSiteManagementClient.webApps.get(
    resourceGroupName,
    appServiceName
);
await webSiteManagementClient.webApps.start(
    resourceGroupName,
    appServiceName
);

// Open the Azure App Service in a web browser
const appServiceUrl = `https://${appService.defaultHostName}`;
const open = require("open");
open(appServiceUrl);
