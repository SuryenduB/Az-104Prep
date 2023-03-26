# Input bindings are passed in via param block.
param([byte[]] $InputBlob, $TriggerMetadata)

$SrcStgAccURI = "https://az10407rg02303270133.blob.core.windows.net/"
$SrcSASToken = "SASToken"
$ContainerName = "az104-07-container"

$DstStgAccURI = "https://az10407rg12303270133.blob.core.windows.net/"
$DstSASToken = "DESTSASToken"

$SrcFullPath = "$($SrcStgAccURI)$($ContainerName)/$($SrcSASToken)"
$DstFullPath = "$($DstStgAccURI)$($ContainerName)/$($DstSASToken)"

$WantFile = 'azcopy.exe'
$AzCopyExists = Test-Path $WantFile

if ($AzCopyExists -eq $False) {
    Start-BitsTransfer -Source 'https://aka.ms/downloadazcopy-v10-windows' -Destination 'AzCopy.zip' 
    Expand-Archive ./AzCopy.zip ./AzCopy -Force
    Get-ChildItem ./AzCopy/*/azcopy.exe | Copy-Item -Destination './AzCopy.exe' 
}

#Backing Up

$env:AZCOPY_JOB_PLAN_LOCATION = $env:temp + '\.azcopy'
$env:AZCOPY_LOG_LOCATION = $env:temp + '\.azcopy'

./azcopy.exe copy $SrcFullPath $DstFullPath --overwrite=ifsourcenewer --recursive

# Write out the blob name and size to the information log.
Write-Host "PowerShell Blob trigger function Processed blob! Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"
