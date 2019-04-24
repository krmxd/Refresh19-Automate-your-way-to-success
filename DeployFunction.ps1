Import-Module az.storage
Import-module az.websites

@('Microsoft.Web', 'Microsoft.Storage') | ForEach-Object {
    Register-AzResourceProvider -ProviderNamespace $_
}

$resourceGroupName = 'refresh19'
$location = 'westeurope'
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (!$resourceGroup) {
    try {
        $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location -ErrorAction stop
    }
    Catch {
        $_.Exception.Message
        exit
    }
}



Try {
    $storageAccountName = "refresh19$((New-Guid).ToString().Split('-')[0])"
    $storageSku = 'Standard_LRS'
    $storageParams = @{
        ResourceGroupName = $resourceGroupName
        AccountName       = $storageAccountName
        Location          = $location
        SkuName           = $storageSku
    }
    $storageAccount = New-AzStorageAccount @storageParams -ErrorAction stop
}
Catch {
    $_.Exception.Message
    exit
}

try {
    $key1 = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -ErrorAction stop).value[0] 
    $storageConnectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$key1"

    $functionAppName = 'Tier2Example'
    $newFunctionAppParams = @{
        ResourceType      = 'Microsoft.Web/Sites'
        ResourceName      = $functionAppName
        Kind              = 'functionapp'
        Location          = $location
        ResourceGroupName = $resourceGroupName
        Properties        = @{ }
        Force             = $true
    }
    $functionApp = New-AzResource @newFunctionAppParams -ErrorAction stop
}
catch {
    $_.Exception.Message
    exit
}

try {

    $functionAppSettings = @{
        AzureWebJobDashboard                     = $storageConnectionString
        AzureWebJobsStorage                      = $storageConnectionString
        FUNCTIONS_EXTENSION_VERSION              = '~1'
        WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = $storageConnectionString
        WEBSITE_CONTENTSHARE                     = $storageAccountName
    }
    $setWebAppParams = @{
        Name              = $functionAppName
        ResourceGroupName = $resourceGroupName
        AppSettings       = $functionAppSettings
    }
    $webApp = Set-AzWebApp @setWebAppParams -ErrorAction stop
}
catch {
    $_.Exception.Message
    exit
}

Try {
    #Deploy the Tier2Example code
    $functionName = 'Tier2Example'
    $functionContent = Get-Content ./Tier2Example/run.ps1 -raw -ErrorAction stop
    $functionSettings = Get-Content ./Tier2Example/function.json -ErrorAction stop | ConvertFrom-Json 
    $functionResourceId = '{0}/functions/{1}' -f $functionapp.resourceid, $functionName
    $functionProperties = @{
        config = @{bindings = $functionSettings.bindings
        }
        files  = @{
            'run.ps1' = "$functionContent"
        }
    }
    $newFunctionParams = @{
        ResourceID = $functionResourceId
        Properties = $functionProperties
        Apiversion = '2015-08-01'
        Force      = $true
    }
    $function = New-AzResource @NewfunctionParams -ErrorAction stop
}
catch {
    $_.Exception.Message
    exit
}


try {
    $functionParams = @{
        ResourceId = $function.ResourceId
        Action     = 'listsecrets'
        ApiVersion = '2015-08-01'
        Force      = $true
    }

    $functionTrigger = Invoke-AzResourceAction @functionParams -ErrorAction Stop
    #$functionTrigger.trigger_url
}
catch {
    $_.Exception.Message
    Write-output "Error retrieving trigger URL. Please visit the Azure Portal"
}

Write-Output "Deployment finished"
Write-Output "Your deployment trigger URL: $($functionTrigger.trigger_url)"
$($functionTrigger.trigger_url) | Add-content triggerUrl.txt
