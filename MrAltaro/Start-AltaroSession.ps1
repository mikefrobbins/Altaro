#Requires -Version 3.0
function Start-MrAltaroSession {

<#
.SYNOPSIS
    Starts a new session with the RESTful API of an Altaro VM Backup server.
 
.DESCRIPTION
    Start-MrAltaroSession is an advanced function that starts a new session with the RESTful API of an
    Altaro VM Backup server. In it current interation, the Altaro RESTful API can only be used locally
    on the Altaro VM Backup server.
 
.PARAMETER ComputerName
    Name of the Altaro VM Backup server. The default is localhost. Currently, the Altaro API only works
    with localhost. $env:COMPUTERNAME or the actual computer name does not work.

.PARAMETER Port
    Port number that the Altaro VM Backup API is listening on. The default is 35113.

.PARAMETER Credential
    The credentials for connecting to the Altaro VM Backup API.
 
.EXAMPLE
     Start-MrAltaroSession -Credential (Get-Credential)

.EXAMPLE
     Start-MrAltaroSession -ComputerName localhost -Credential (Get-Credential)

.EXAMPLE
     Start-MrAltaroSession -ComputerName localhost -Port 35113 -Credential (Get-Credential)

.INPUTS
    None
 
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
        
        [Parameter(Mandatory)]
        [System.Management.Automation.Credential()]$Credential
    )
    
    $Uri = "http://$ComputerName`:$Port/api/sessions/start"

    $Body = @{
        ServerAddress = $ComputerName 
        ServerPort = '35107' 
        Username = $Credential.UserName -replace '^.*\\'
        Password = $Credential.GetNetworkCredential().Password
        Domain = $Credential.UserName -replace '\\.*$'
    } | ConvertTo-Json
    
    try {
        $Results =  Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json' -Body $Body
    }
    catch {
        Write-Error -Message "Unable to connect to Altaro API at: $Uri"
    }

    if ($Results.Success -eq $true) {    
        [PSCustomObject]@{
            SessionId = [guid]$Results.Data
        }
    }
    elseif ($Results.Success -eq $false) {
        Write-Error -Message "$($Results.ErrorMessage). Error Code: $($Results.ErrorCode). $($Results.ErrorAdditionalDetails)"
    }
}