
[string]$freshTenant = "" # Please enter your fresh tenantname. Example <YOUR-TENANT-NAME>.freshservice.com. 
[string]$APIKey = '' # Please enter a API key here.
[int]$catalogItemNumber = 61 # You can find your catalogItemNumber in de url.

## Do not edit below this line
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $APIKey, $null)))
$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ("Basic {0}" -f $EncodedCredentials))
$HTTPHeaders.Add('Content-Type', 'application/json')


$uri = "https://$($freshTenant).freshservice.com/catalog/items/$($catalogItemNumber).json"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$srDetails = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $uri -Headers $HTTPHeaders

Write-output "Catalog default items:"
$srDetails.catalog_item
Write-output "Catalog your custom fields:"
$srDetails.catalog_item.custom_fields