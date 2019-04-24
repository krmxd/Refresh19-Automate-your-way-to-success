# Refresh19-Automate-your-way-to-success
Contains the freshservice automation starter kit, used in the Refresh19 presentation

## Thank you for visiting
I hope you enjoyed refresh19 as much as I did.

## How to use this repo

### Requirements
We've decided to build this starterkit based on Azure Functions and make use of Powershell.

Azure Functions because it's free! 
Get your free account [here] (https://azure.microsoft.com/free/)

Powershell mostly because it's not that hard to start with and has a great community to help out with any question.
Read more on powershell [here] (https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-6) if you are new to Powershell. And yes, Mac and Linux users aren't left out. 

### Step 1. Get your free Azure account running
Signup using the link above. Without a Azure subscription we can't move forward.

### Step 2. Create a new service request
Create a new service request for this demo. 
 Item Name: refresh19demo
 Short Description: refresh19demo
 Description: refresh19demo

Just add a single line textbox and name it "textinput"

At the bottom of the screen edit the subject and change it to:
{{item.name}}

Save and Publish

### Step 3. Get the service request details.
For this you can make use to GetCatalogItemDetails.ps1

Make sure you edit the script and update the following lines:
```
[string]$freshTenant = "" # Please enter your fresh tenantname. Example <YOUR-TENANT-NAME>.freshservice.com. 
[string]$APIKey = '' # Please enter a API key here.
[int]$catalogItemNumber =  # You can find your catalogItemNumber in de url.
```

Run the script and you can see every piece of information you might need to automate requests etc. For now, we don't need any information because we know the fieldname and thats all we need now.

### Step 4. 
If you are new to Powershell. Install powershell if you are running MacOs or a Linux distribution, if you are running windows, install the latest version of [AZ-Modules] (https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.8.0)



### Step 5.

### Step 6.