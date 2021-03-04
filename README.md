# Start/Stop an Azure VM With a Webhook
  This runbook uses an Azure Run As Account to start or stop an Azure VM. A webhook is used to trigger the runbook.
  An AzureRunAsConnection name is used to connect to the Azure Run As Account. A VM name and ResourceGroup name are
  used to find and start or stop a VM.
  This script searches the WebhookData's RequestBody for a JSON object that contains the instuction to start or stop
  the corresponding VM.
 
## Helpful documentation
  - [Tutorial: Create a PowerShell runbook](https://docs.microsoft.com/en-us/azure/automation/learn/automation-tutorial-runbook-textual-powershell)
  - [Start a runbook from a webhook](https://docs.microsoft.com/en-us/azure/automation/automation-webhooks)
