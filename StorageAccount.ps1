Connect-AzAccount -SubscriptionId $subscriptionId

#Parameters

$ResourceGroupName = "Az104-Prep"
$StorageAccountName = "az104acjjaskdasvda"
$SkuName = "Standard_LRS"
$Location = "WestEurope"

#ResourceGroup

$resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location 


#Storage

New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $Location -SkuName $SkuName 



