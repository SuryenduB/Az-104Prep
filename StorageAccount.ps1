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
