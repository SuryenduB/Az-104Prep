Connect-AzAccount

$ResourceGroup = "Az104-Chapter10"
$Location = "WestEurope"
$SubscriptionId = "49968c9d-df22-43b7-a330-f7e8bf2c7595"
$AvailabilitySetName = "SuryVMAvailabilitySet"
$VirtualNetworkName = 'MyVnet'
$SubnetName = "SuryVMSubnet"
$VMName = "SuryVM"
$vmSize = "Standard_DS1_v2"
$NSGName = "$VMName-nsg"


Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name "$ResourceGroup" -Location $Location

$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix 10.0.0.0/24

$parameters1 = @{
    Name = "$VirtualNetworkName"
    ResourceGroupName = "$ResourceGroup"
    Location = "$Location"
    AddressPrefix = '10.0.0.0/16'
    Subnet = $subnetConfig
}

$vnet = New-AzVirtualNetwork @parameters1

$subnetid = (Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet ).Id
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Location $Location -Name $NSGName


New-AzAvailabilitySet `
-ResourceGroupName "$ResourceGroup" `
-Name $AvailabilitySetName `
-Location $Location `
-Sku aligned `
-PlatformFaultDomainCount 2 `
-PlatformUpdateDomainCount 2

$adminUsername = 'Student'
$adminPassword = 'Pa55w.rd1234'

$Creds = New-Object PSCredential $adminUsername , ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)



for($vmNum=1; $vmNum -le 2; $vmNum++){
    New-AzPublicIpAddress -Name "$VmName-pip-$vmNum" -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Dynamic
}



for($vmNum=1; $vmNum -le 2; $vmNum++){
    New-AzVM `
    -ResourceGroupName $ResourceGroup `
    -Name "$VmName-$vmNum" `
    -Location $Location `
    -VirtualNetworkName $VirtualNetworkName `
    -SubnetName $SubnetName `
    -SecurityGroupName $NSGName `
    -PublicIpAddressName "$VmName-pip-$vmNum" `
    -AvailabilitySetName $AvailabilitySetName `
    -Credential $Creds
}