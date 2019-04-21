$myVaultName = ""   #Your Azure vault for retrieving secrets (don't store APIkeys and password in plaintext)
$mySecretName = ""  #Name of the secret you need to retrieve. Example FreshApiKey
$freshTenant = ""   # Please enter your fresh tenantname. Example <YOUR-TENANT-NAME>.freshservice.com. 

#Working with the incomming request body
$requestBody = Get-Content $req -Raw 
$convertedBody = $requestBody | convertfrom-json
$freshTicket = $convertedBody.freshdesk_webhook.ticket_id.Split('-')[1]

#Set Rest methods to TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-VaultSecret {
    param (
        $vaultName,
        $secretName
    )
    
    $tokenAuthURI = $Env:MSI_ENDPOINT + "?resource=https://vault.azure.net&api-version=2017-09-01"
    $tokenResponse = Invoke-RestMethod -Method Get -Headers @{"Secret"="$env:MSI_SECRET"} -Uri $tokenAuthURI
    $accessToken = $tokenResponse.access_token

    $headers = @{ 'Authorization' = "Bearer $accessToken" }
    $queryUrl = "https://$vaultName.vault.azure.net/secrets/" +$secretName + "?api-version=2016-10-01"

    $getResponse = Invoke-RestMethod -Method GET -Uri $queryUrl -Headers $headers
    return $getResponse
}

#build header
$APIKey = (Get-VaultSecret -vaultName $myVaultName -secretName $mySecretName).value
$EncodedCredentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $APIKey,$null)))
$HTTPHeaders = @{}
$HTTPHeaders.Add('Authorization', ("Basic {0}" -f $EncodedCredentials))
$HTTPHeaders.Add('Content-Type', 'application/json')


#Retrieve the request from fresh based on the ticketnumber
$URL = "https://$($freshTenant).freshservice.com/helpdesk/tickets/$($freshTicket)/requested_items.json"
$requestData = Invoke-RestMethod -Method Get -Uri $URL -Headers $HTTPHeaders

#Update the request that we are working on the request
$ticketResponse = '{ "helpdesk_note": { "body":"Hi, Tier2 retrieved the request data", "private":false }}'
$urlResponse = "https://$($freshTenant).freshservice.com/helpdesk/tickets/$($freshTicket)/conversations/note.json"
Invoke-RestMethod -Method Post -Body $ticketResponse -Uri $urlResponse -Headers $HTTPHeaders


$body = @{
    freshTicket = $freshTicket
    SomeCustomField1 = $($requestData.requested_item.requested_item_values.SomeCustomField1)
    SomeCustomField2 = $($requestData.requested_item.requested_item_values.SomeCustomField2)
    SomeCustomField3 = $($requestData.requested_item.requested_item_values.SomeCustomField3)
    SomeCustomField4 = $($requestData.requested_item.requested_item_values.SomeCustomField4)
    SomeCustomField5 = $($requestData.requested_item.requested_item_values.SomeCustomField5)
}

$webhookurl = '' # Enter here the WebhookUrl for your backend system(Tier3). 

 $params = @{
    ContentType = 'application/json'
    Headers     = @{'from' = "Azure Function call via Fresh"; 'Date' = "$(Get-Date)"}
    Body        = ($body | convertto-json)
    Method      = 'Post'
    URI         = $webhookurl
}

$triggerTier3 = Invoke-RestMethod @params 

Out-File -Encoding Ascii -FilePath $res -inputObject $triggerTier3