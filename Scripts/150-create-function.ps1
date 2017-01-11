$ErrorActionPreference = "Stop"
$scriptDir=($PSScriptRoot, '.' -ne "")[0]
. "$scriptDir\Include\common.ps1"

Write-Host "Create a Function App..."  -ForegroundColor Green

#Comments: the link did not work for me. Maybe add more precise instructions how to navigate on the Portal.
# Should I create a seperate Storage for Function App or can I use the one that is already created?

Write-Host -ForegroundColor Magenta "Perform this manual configuration"
Write-Host -ForegroundColor Magenta "`nNavigate to:"
$sub=(Get-AzureRmContext).Subscription.SubscriptionId
Write-Host -ForegroundColor Magenta "https://portal.azure.com/#blade/WebsitesExtension/FunctionsIFrameBlade/id/%2Fsubscriptions%2F$sub%2FresourceGroups%2F$resourceGroupName%2Fproviders%2FMicrosoft.Web%2Fsites%2F$functionAppName"
Write-Host -ForegroundColor Magenta "`nCreate new resource of type Function App, name '$functionAppName'. When Function App is created, navigate to it."
Write-Host -ForegroundColor Magenta "`nOn the welcome screen click New Function -> Select WebHook+Api -> Select CSharp. Then Select New Function -> Choose GenericWebHook-Csharp template -> Name your function '$functionName'. Paste following code: "
Write-Host -ForegroundColor Cyan    (Get-Content -Path ..\Resources\PostToEventHubFunction\run.csx -Raw)

#Doesn't work correctly
function createFunction() {

$templateFilePath = "..\Resources\PostToEventHubFunction\functionAppTemplate.json"
if (-Not (Get-AzureRmWebApp  -ResourceGroupName $resourceGroupName -Name $functionAppName -ErrorAction SilentlyContinue)) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterObject @{location=$location; storageAccount=$functionAppName; functionApp=$functionAppName}
}

Write-Host "Create a Function..."  -ForegroundColor Green

$props = @{
    config = @{
        bindings = @(
            @{
                direction = "in"
                name = "req"
                type = "httpTrigger"
                webHookType = "genericJson"
            }
            @{
                direction = "out"
                name = "res"
                type = "http"
            }
            @{
                connection = "$eventHubName"
                direction = "out"
                name = "outputEventHubMessage"
                path = "$eventHubName"
                type = "eventHub"
            }
        )
    }
    files = @{
		"run.csx" = "$(Get-Content -Path ..\Resources\PostToEventHubFunction\run.csx -Raw)"
	}
}

New-AzureRmResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Web/sites/functions -ResourceName $functionAppName/$functionName -PropertyObject $props -ApiVersion 2015-08-01 -Force

}

# These commands were not executed because they are part of the function that is not called. I moved them outside. ###
$sub=(Get-AzureRmContext).Subscription.SubscriptionId
$eventHubSendPolicyKey=(Get-AzureRmEventHubNamespaceKey -ResourceGroupName $resourceGroupName -NamespaceName $eventHubNamespace -AuthorizationRuleName $eventHubSendPolicyName).PrimaryConnectionString
Write-Host -ForegroundColor Magenta "Perform this manual configuration"
Write-Host -ForegroundColor Magenta "`nNavigate to:"
Write-Host -ForegroundColor Magenta "https://portal.azure.com/#blade/WebsitesExtension/FunctionsIFrameBlade/id/%2Fsubscriptions%2F$sub%2FresourceGroups%2F$resourceGroupName%2Fproviders%2FMicrosoft.Web%2Fsites%2F$functionAppName"
Write-Host -ForegroundColor Magenta "`nClick PostToEventHub -> Integrate -> Configure event hub:"


Write-Host -ForegroundColor Magenta "`nEvent hub name:"
Write-Host -ForegroundColor Cyan     $eventHubName
Write-Host -ForegroundColor Magenta "Event hub connection: new, Connection name:"
Write-Host -ForegroundColor Cyan     $eventHubNamespace
Write-Host -ForegroundColor Magenta "Connection string:"
Write-Host -ForegroundColor Cyan     $eventHubSendPolicyKey



