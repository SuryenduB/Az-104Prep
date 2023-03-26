$resourceGroup1 = "az104-07-rg0"
$resourceGroup2 = "az104-07-rg1"
$Location = "westeurope"


$date = Get-Date -Format "yyMMddhhmm"
$skuName = "Standard_LRS"
$StorageAccountName1 = "$($resourceGroup1.ToLower() -replace("-"))$date"
$StorageAccountName2 = "$($resourceGroup2.ToLower() -replace "-")$date"


New-AzStorageAccount -Name $StorageAccountName1 -ResourceGroupName $resourceGroup1 -Location $Location -SkuName $skuName
New-AzStorageAccount -Name $StorageAccountName2 -ResourceGroupName $resourceGroup2 -Location $Location -SkuName $skuName


#Create and Configure Azure Files

$ShareName = "az104-07-share"
$Context1 = (Get-AzStorageAccount -ResourceGroupName $ResourceGroup1 -AccountName $StorageAccountName1).Context
$Context2 = (Get-AzStorageAccount -ResourceGroupName $ResourceGroup2 -AccountName $StorageAccountName2).Context

New-AzStorageShare -Name $ShareName -Context $Context1
New-AzStorageShare -Name $ShareName -Context $Context2

#Blob and Container

$ContainerName = "az104-07-container"
New-AzStorageContainer -Name $ContainerName -Context $Context1 -Permission Blob
New-AzStorageContainer -Name $ContainerName -Context $Context2 -Permission Blob

$appServicePlanName = "az104-07-appsp-$date"
$azureFunctionApp = "az10407function-$date"

New-AzAppServicePlan -ResourceGroupName $resourceGroup1 -Name $appServicePlanName -Location $Location -Tier Basic -NumberofWorkers 1 -WorkerSize "Small"
New-AzFunctionApp -Name "$azureFunctionApp" -ResourceGroupName $resourceGroup1 -PlanName $appServicePlanName -StorageAccountName $StorageAccountName1 -Runtime PowerShell