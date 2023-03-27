$resourceGroup1 = "az104-07-rg0"
$Location = "westeurope"
New-AzResourceGroup -Name $resourceGroup1 -Location $Location
$ShareName = "az104-07-share"
$subnetName = "myBackendSubnet"

$date = Get-Date -Format "yyMMddhhmm"
$skuName = "Standard_LRS"
$StorageAccountName1 = "$($resourceGroup1.ToLower() -replace("-"))$date"
New-AzStorageAccount -Name $StorageAccountName1 -ResourceGroupName $resourceGroup1 -Location $Location -SkuName $skuName

$Context1 = (Get-AzStorageAccount -ResourceGroupName $resourceGroup1 -AccountName $StorageAccountName1).Context
New-AzStorageShare -Name $ShareName -Context $Context1

$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24
$parameters1 = @{
    Name = 'MyVnet'
    ResourceGroupName = "$resourceGroup1"
    Location = "$Location"
    AddressPrefix = '10.0.0.0/16'
    Subnet = $subnetConfig
}

$vnet = New-AzVirtualNetwork @parameters1

$adminUsername = 'Student'
$adminPassword = 'Pa55w.rd1234'

$adminCreds = New-Object PSCredential $adminUsername , ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)
$OperatingSystemParameters = @{
    PublisherName = 'MicrosoftWindowsServer'
    Offer = 'WindowsServer'
    Skus = '2019-Datacenter'
    Version = 'latest'
}

$vmName = "myVM"
$vmSize = "Standard_DS1_v2"
$NSGName = "$vmName-nsg"

$subnetid = (Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet ).Id
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup1 -Location $Location -Name $NSGName

$nsgParams = @{
    'Name' = 'allowRDP'
    'NetworkSecurityGroup' = $NSG
    'Protocol' = 'TCP'
    'Direction' = 'Inbound'
    'Priority' = 200
    'SourceAddressPrefix' = '*'
    'SourcePortRange' = '*'
    'DestinationAddressPrefix' = '*'
    'DestinationPortRange' = 3389
    'Access' = 'Allow'

}

Add-AzNetworkSecurityRuleConfig @nsgParams | Set-AzNetworkSecurityGroup

$pip = New-AzPublicIpAddress -Name "$vmName-pip" -ResourceGroupName $resourceGroup1 -Location $Location -AllocationMethod Dynamic
$nic = New-AzNetworkInterface -Name "$($vmName)$(Get-Random)" -ResourceGroupName $resourceGroup1 -Location $Location -SubnetId $subnetid -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id

$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $adminCreds
Set-AzVMSourceImage -VM $vmConfig @OperatingSystemParameters   
Set-AzVMOSDisk -VM $vmConfig -Name "$($vmName)_OSDisk_1_1$(Get-Random)" -CreateOption fromImage

Set-AzVMBootDiagnostic -VM $vmConfig -Disable

New-AzVM -ResourceGroupName $resourceGroup1 -Location $Location -VM $vmConfig

$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup1 -Name $StorageAccountName1

$privateEndpointConnection = New-AzPrivateLinkServiceConnection -Name 'myConnection' -PrivateLinkServiceId ($storageAccount.Id) -GroupId 'file'
$vnet.Subnets[0].PrivateEndpointNetworkPolicies="Disabled"
$vnet | Set-AzVirtualNetwork

New-AzPrivateEndpoint -ResourceGroupName $resourceGroup1 `
    -Name 'myPrivateEndpoint' `
    -Location $Location `
    -Subnet ($vnet.Subnets[0]) `
    -PrivateLinkServiceConnection $privateEndpointConnection
            