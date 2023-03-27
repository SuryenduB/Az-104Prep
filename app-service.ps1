Connect-AzAccount

$ResourceGroup = "Az104-Chapter12"
$Location = "WestEurope"
$SubscriptionId = "49968c9d-df22-43b7-a330-f7e8bf2c7595"
$WebAppName = "myfirstwebappsury27032023"
$AppServicePlanName = "mylinuxappserviceplan"

Select-AzSubscription -SubscriptionId $SubscriptionId

New-AzResourceGroup -Name "$ResourceGroup" -Location $Location

New-AzAppServicePlan `
-Name $AppServicePlanName `
-Tier Standard `
-Location $Location `
-Linux  `
-NumberofWorkers 1 `
-WorkerSize Small `
-ResourceGroupName $ResourceGroup

New-AzWebApp -Name $WebAppName -ResourceGroupName $ResourceGroup -Location $Location -AppServicePlan $AppServicePlanName

$AppServicePlan = Get-AzAppServicePlan -Name $AppServicePlanName -ResourceGroupName $ResourceGroup

$AutoScaleRule = New-AzAutoscaleRule -MetricName "CpuPercentage" -Operator "GreaterThan" -MetricStatistic "Average" -Threshold 70 -TimeAggregationOperator Average -TimeGrain "00:01:00" -TimeWindow "00:10:00" -MetricResourceId $AppServicePlan.Id -ScaleActionCooldown 00:10:00 -ScaleActionDirection Increase -ScaleActionScaleType ChangeCount -ScaleActionValue 1
$AutoScaleProfile = New-AzAutoscaleProfile -Name "AutoScaleProfile" -DefaultCapacity 1 -MaximumCapacity 2 -MinimumCapacity 1 -Rule $AutoScaleRule

Add-AzAutoscaleSetting -Location $Location -Name "Auto Scale Setting" -ResourceGroupName $ResourceGroup -TargetResourceId $AppServicePlan.Id -AutoscaleProfile $AutoScaleProfile
