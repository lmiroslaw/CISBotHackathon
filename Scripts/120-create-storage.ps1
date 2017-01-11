#I think this variable has already been defined in Config . No need to do it again here. The same applies to othe scripts.
$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1" 

#region - create storage account (for ADF U-SQL script, as well as ML data)
if (-Not(Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue)) {
    New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS
    New-AzureStorageContainer -Context (getStorageContext) -Name adf-resources
    New-AzureStorageContainer -Context (getStorageContext) -Name interaction-data
}
#endregion
