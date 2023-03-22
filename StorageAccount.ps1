Connect-AzAccount -SubscriptionId $subscriptionId

#Parameters

$ResourceGroupName = "Az104-Prep"
$StorageAccountName = "az104acjjaskdasvda"
$ContainerName = "test1"
$ShareName = "testshare"
$SkuName = "Standard_LRS"
$Location = "WestEurope"

#ResourceGroup

$resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location 


#Storage

New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $Location -SkuName $SkuName 

#Storage Context

$Context = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).Context

#Blob Container

New-AzStorageContainer -Name $ContainerName -Context $Context
New-AzStorageShare -Name $ShareName -Context $Context


$storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$privateEndpointConnection = New-AzPrivateLinkServiceConnection -Name 'myConnection' -PrivateLinkServiceId ($storageAccount.Id) -GroupId 'file';
$vnet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name "StorageVnet"

$vnet.Subnets[0].PrivateEndpointNetworkPolicies = 'Disabled'
$vnet | Set-AzVirtualNetwork

New-AzPrivateEndpoint -ResourceGroupName $ResourceGroupName -Name "myPrivateEndpoint" -Location "westeurope" -Subnet ($vnet.Subnets[0]) -PrivateLinkServiceConnection $privateEndpointConnection