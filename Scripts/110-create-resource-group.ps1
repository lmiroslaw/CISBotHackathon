# Minimal requirement: Powershell version 3.3

# If you run into problems:
# 1. Run this command to check your Powershell version
# (Get-Module -ListAvailable | Where-Object{ $_.Name -eq 'Azure' }) | Select Version, Name, Author, PowerShellVersion  | Format-List;
# 2. Use Windows Web Installer to update Azure for Powershell: https://www.microsoft.com/web/downloads/platform.aspx

$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1" 

#region - Create a Resource Group
Write-Host "Create a resource group ..." -ForegroundColor Green
New-AzureRmResourceGroup `
    -Name  $resourceGroupName `
    -Location $location
#endregion
