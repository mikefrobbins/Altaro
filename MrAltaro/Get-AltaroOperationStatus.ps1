#Requires -Version 3.0
function Get-MrAltaroOperationStatus {

<#
.SYNOPSIS
    Retrieves the status and progress for Altaro VM Backup jobs which are currently running.
 
.DESCRIPTION
    Get-MrAltaroOperationStatus is an advanced function that retrieves the status and progress for Altaro
    VM Backup jobs (backups, offsite copies, restores, seed to disks) which are currently running.
 
.PARAMETER ComputerName
    Name of the Altaro VM Backup server. The default is localhost. Currently, the Altaro API only works
    with localhost. $env:COMPUTERNAME or the actual computer name does not work.

.PARAMETER Port
    Port number that the Altaro VM Backup API is listening on. The default is 35113.

.PARAMETER SessionId
    The Id in the form of a GUID for the sesison created by Start-MrAltaroSession.

.PARAMETER OperationId
    The Id in the form of a GUID for the specific operation to return results for.
 
.EXAMPLE
     Get-MrAltaroOperationStatus -SessionId b3019809-cfbe-4ac6-93df-a24c91b5b28e

.EXAMPLE
     Get-MrAltaroOperationStatus -SessionId b3019809-cfbe-4ac6-93df-a24c91b5b28e -OperationId 1351d928-0391-4a45-8d5a-ae4b806bea66

.EXAMPLE
     Get-MrAltaroOperationStatus -ComputerName localhost -Port 35113 -SessionId b3019809-cfbe-4ac6-93df-a24c91b5b28e

.INPUTS
    Guid
 
.OUTPUTS
    PSCustomObject
 
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [Alias('ServerName')]
        [string]$ComputerName = 'localhost',
        
        [ValidateNotNullOrEmpty()]
        [int]$Port = 35113,
        
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [guid]$SessionId,

        [guid]$OperationId
    )

    PROCESS {    
        $uri = "http://$ComputerName`:$Port/api/activity/operation-status/$SessionId"
        
        Invoke-RestMethod -Uri $uri -Method Get -ContentType 'application/json' |
        Select-Object -ExpandProperty Statuses
    }

}