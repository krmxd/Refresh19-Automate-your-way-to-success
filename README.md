# Refresh19-Automate-your-way-to-success
Contains the freshservice automation starter kit, used in the Refresh19 presentation

## Thank you for visiting
I hope you enjoyed refresh19 as much as I did.

## How to use this repo

### Requirements
We've decided to build this starterkit based on Azure Functions and make use of Powershell.

Azure Functions because it's free! 
Get your free account [here](https://azure.microsoft.com/free/)

Powershell mostly because it's not that hard to start with and has a great community to help out with any question.
Read more on powershell [here](https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-6) if you are new to Powershell. And yes, Mac and Linux users aren't left out. 

Make sure you download or clone the contents of this repo and run everything that you do from the root of that specific folder.

### Step 1. Get your free Azure account running
Signup using the link above. Without a Azure subscription we can't move forward.

### Step 2. Create a new service request
Create a new service request for this demo. 
1. Item Name: refresh19demo
2. Short Description: refresh19demo
3. Description: refresh19demo

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

### Step 4. Logon to Azure using Powershell
If you are new to Powershell. Install powershell if you are running MacOs or a Linux distribution, if you are running windows, install the latest version of [AZ-Modules](https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.8.0)


Login to your Azure Subscription using Connect-AzAccount


### Step 5. Deploy the Tier2 function
You can now run DeployFunction.ps1 to deploy the Tier2 funtion

When the deployment is finished, you can validate the deployment by logging in to the azure portal and take a look at the AzureFunctions section and see the deployed function.

### Step 6. Update the function with your specific tenant details

Make sure you read the code in the deployed function, you can use it as a template to send request to backend systems.

For now it's going to update the ticket with a note that Tier2 processing was completed.

Don't forget to enter your fresh tenantname and enter a apikey.

### Step 7. Configure the automator to trigger Tier 2

Logon to your freshservice environment, navigate to the admin, click on the Admin and then click automator.

Create a new automator with the following steps.
New Automator --> Tickets --> Name: refresh19demo --> create

1. Event --> When a ServiceRequest is raised
2. Condition --> And the subject is "refresh19demo"
3. Action --> Set the status as pending
4. Action --> Trigger webhook :
Request type: Post
Callback URL: The url of the azure function. This was generated during the deployment. (you can find a copy in the triggerUrl.txt in the working directory)
* Encoding: JSON
* Select SIMPLE mode
* Content : Ticket ID

Active the automator workflow.

### Step 8. Create a new service request based on refresh19demo

And watch Tier2 add a note to the ticket.

### Happy automation!!