# Login & set appropriate subscription
az login
az account show
az account set --subscription <subscription-id>

# Define a variable which we will use later
resourceGroupName=azecommstore

# Create the resource group
az group create --name $resourceGroupName --location australiaeast

# Define variable, which we will use later
apimName=azecommstoreapimae

# Create APIM instance with managed identity enabled
az apim create --name $apimName --resource-group $resourceGroupName --location australiaeast --publisher-name Sanjay --publisher-email admin@gmail.com --sku-name Consumption --enable-managed-identity true

az apim api create --service-name $apiName -g $resourceGroupName --api-id Orders --path '/orders' --display-name 'Orders'

az apim api operation create --resource-group $resourceGroupName --service-name $apimName --api-id Orders --url-template "/process/{geography}" --method "POST" --display-name 'Process Orders' --description 'Process Orders for E-Store'

# Define variable, which we will use later
serviceBusNamespace=azsbnsorders

# Create a namespace with standard SKU
az servicebus namespace create --name $serviceBusNamespace --resource-group $resourceGroupName --location australiaeast --sku Standard

# Create Service Bus Topic
az servicebus topic create --name orders --resource-group $resourceGroupName --enable-partitioning false --namespace $serviceBusNamespace

# Create Subscription for the topic
az servicebus topic subscription create --name sydneyorders --resource-group $resourceGroupName --namespace-name $serviceBusNamespace --topic-name orders

# Create Rule for the subscription
az servicebus topic subscription rule create --resource-group $resourceGroupName --namespace-name $serviceBusNamespace --topic-name orders --subscription-name sydneyorders --name processorders --filter-sql-expression "originUrl='/orders/process/sydney'"

# Get the subscription id
subscriptionId=$(az account show --query id --output tsv)

# Get the objectId of the APIM instance (system-assigned managed identity)
assigneeId=$(az apim show --name $apimName --resource-group $resourceGroupName --query 'identity.principalId' --out tsv)

# Finally, assign the permissions Azure Service Bus namespace
az role assignment create --role "Azure Service Bus Data Sender" --assignee $assigneeId --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ServiceBus/namespaces/$serviceBusNamespace

# Create Storage Account
az storage account create --name azecommstorestorage --resource-group $resourceGroupName --location australiaeast --sku Standard_LRS

# Create function app
az functionapp create --resource-group $resourceGroupName --consumption-plan-location australiaeast --name sydneyordersprocessor --storage-account azecommstorestorage --runtime dotnet-isolated --functions-version 4 --os-type Linux

# Clean up resources
az group delete --name $resourceGroupName

