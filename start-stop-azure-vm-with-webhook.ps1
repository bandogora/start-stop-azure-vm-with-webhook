<#
.SYNOPSIS
    This runbook uses an Azure Run As Account to start or stop an Azure VM. A webhook is used to trigger the runbook
    and supply the start/stop data.

.DESCRIPTION
    This runbook uses an Azure Run As Account to start or stop an Azure VM. A webhook is used to trigger the runbook.
    An AzureRunAsConnection name is used to connect to the Azure Run As Account. A VM name and ResourceGroup name are
    used to find and start or stop a VM.
    This script searches the WebhookData's RequestBody for a JSON object that contains the instuction to start or stop
    the corresponding VM.

.NOTES
    This runbook requires the Azure, Az.Accounts, and Az.Compute modules.

    If you do not edit this script the HTTP POST request made to your webhook should contain the JSON object
    `{ "action": "start" }` or `{ "action": "stop" }` in the body.

.PARAMETER VMName
    A mandatory param that needs to be set to the name of the VM you want to target.

.PARAMETER ResourceGroupName
    A mandatory param that needs to be set to the name of the ResourceGroup you want to target.

.PARAMETER AzureRunAsConnectionName
    An optional param that needs to be set to the name of the AzureRunAsConnection you want to target.
    The default default is "AzureRunAsConnection".
#>

param (
    [Parameter(Mandatory=$true)]
    [String] $VMName,

    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupName,

    [Parameter(Mandatory=$false)]
    [String] $AutomationConnectionName = 'AzureRunAsConnection',

    [object] $WebhookData
)

if ($WebhookData) {
    $body = (ConvertFrom-JSON -InputObject $WebhookData.RequestBody)

    # Check RequestBody for action key and value
    # The key "action" is arbitrary and can be changed to correspond with what your POST request contains
    $action = $body.action
    if (($action -eq 'start') -or ($action -eq 'stop')) {
        Write-Output "VM action: $action"
    }
    else {
        throw 'Required RequestBody data missing or wrong'
    }

    # Find Azure Automation Connection by name
    $connection = Get-AutomationConnection -Name $AutomationConnectionName

    # Connect to Azure Automation Account
    Connect-AzAccount `
            -ServicePrincipal `
            -Tenant $connection.TenantID `
            -ApplicationId $connection.ApplicationID `
            -CertificateThumbprint $connection.CertificateThumbprint

    if ($action -eq 'start') {
        # Start VM
        Start-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -ErrorVariable err
    }
    else {
        # Stop VM
        Stop-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -Force -ErrorVariable err
    }

    if($err) {
        throw $err
    }
    else {
        Write-Output "VM has been ${action}ed"
    }
}
else {
    Write-Error "WebhookData Missing"
}
