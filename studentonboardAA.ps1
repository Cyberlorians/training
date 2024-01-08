param (
    [Parameter (Mandatory = $false)]
    [object] $WebHookData
)

write $WebHookData.RequestBody
$ID = $WebhookData.RequestBody 

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# Set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

#set subscriptionID for RG students
$sub = "ENTER DEDICATED STUDENT SUBSCRIPTIONID"



$baseName = "student"
$range = 1..50

foreach ($i in $range) {
    $rgName = $baseName + [string]::Format("{0:D3}", $i)
    if (Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue) {
        Write-Host "Resource group $rgName already exists."
    } else {
        $newRgName = $rgName
        break
    }
}

if ($newRgName) {
    New-AzResourceGroup -Name $newRgName -Location "eastus"
    Write-Host "Resource group $newRgName created."
               New-AzRoleAssignment -RoleDefinitionName "Owner" -ObjectId "$ID" -Scope "/subscriptions/$sub/resourceGroups/$newRgName"
               Write-Host "Owner assigned to resource group $newRgName."
     } else {
    Write-Host "All resource groups already exist."
}
