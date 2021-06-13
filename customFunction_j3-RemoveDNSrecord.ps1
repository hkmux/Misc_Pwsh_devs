
function J3-RemoveDNSRecord {
    [CmdletBinding()]
    param(
        <#define remove DNS rec param
        [Parameter(Mandatory)]
        [string]$remove#>

        #base of function:
        # Remove-DnsServerResourceRecord -ZoneName vdd1.net -Name host1 -RRType A 

        [Parameter(Mandatory)]
        [string]$rzone,

        [Parameter(Mandatory)]
        [string]$rhost,

        [Parameter(Mandatory)]
        [ValidateSet('A','NS', 'SOA')]
        [string]$remRecType,

        [Parameter()]
        [string]$rIP


    )   
         
    # do some DNS removal stuff!
       
       try {
            Remove-DnsServerResourceRecord -ZoneName $rzone -Name $rhost -RRType $remRecType `
            ?{$_.recorddata -like "$rip"}
       }

       catch {
            write-host " FAILED TO REMOVE HOST $rhost @ $rIP from the $rzone RECORD. CHECK YOUR COMMAND SYNTAX AND TRY AGAIN!! " -ForegroundColor Magenta
       }

       #if alls well, tell its well...
       cls
       Write-Host "`n`n DNS RECORD FOR $rhost SUCCESSFULLY REMOVED!! `n`n`n HERE IS THE UPDATED FORWARD LOOKUP ZONE: ``n`n" -ForegroundColor Cyan
       Get-DnsServerResourceRecord -ZoneName $rzone
       write-host "`n`n Press ENTER to exit/continue..." -ForegroundColor Gray
       Read-Host
}

