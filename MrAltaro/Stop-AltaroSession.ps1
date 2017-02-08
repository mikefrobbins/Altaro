#Requires -Version 3.0
function Stop-MrAltaroSession {

<#
.SYNOPSIS
    Stops one or more sessions with the RESTful API of an Altaro VM Backup server.
 
.DESCRIPTION
    Stop-MrAltaroSession is an advanced function that stops one or more sessions with the RESTful API of
    an Altaro VM Backup server. In it current interation, the Altaro RESTful API can only be used locally
    on the Altaro VM Backup server.
 
.PARAMETER ComputerName
    Name of the Altaro VM Backup server. The default is localhost. Currently, the Altaro API only works
    with localhost. $env:COMPUTERNAME or the actual computer name does not work.

.PARAMETER Port
    Port number that the Altaro VM Backup API is listening on. The default is 35113.

.PARAMETER SessionId
    The Id in the form of a GUID for the sesison created by Start-MrAltaroSession.
 
.EXAMPLE
     Stop-MrAltaroSession

.EXAMPLE
     Stop-MrAltaroSession -SessionId 6d2d22ef-06df-4bb0-976b-bb6a8b3f2683

.EXAMPLE
     Stop-MrAltaroSession -ComputerName localhost -Port 35113 -SessionId 66c09e7d-e10c-4608-b9cd-d35579784e70

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

        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName)]
        [guid]$SessionId
    )

    PROCESS {
        $uri = "http://$ComputerName`:$Port/api/sessions/end"

        if ($PSBoundParameters.SessionId){
            $uri = "$uri/$SessionId"
        }
    
        try {
            $Results =  Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json'
        }
        catch {
            Write-Error -Message "Unable to connect to Altaro API at: $Uri"
        }

        if ($Results.Success -eq $true -and $Results.ClosedSessions.SessionToken -ne $null) {    
            foreach ($Result in $Results.ClosedSessions) {
                [PSCustomObject]@{
                    SessionId = [guid]$Result.SessionToken
                }
            }
        }
        elseif ($Results.Success -eq $true -and $Results.ClosedSessions.SessionToken -eq $null){
            Write-Warning -Message 'There are no open sessions.'
        }
        elseif ($Results.Success -eq $false) {
            Write-Error -Message "$($Results.ErrorMessage). Error Code: $($Results.ErrorCode). $($Results.ErrorAdditionalDetails)"
        }
    }

}