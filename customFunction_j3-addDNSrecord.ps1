
function J3-AddDNSRecord {
    [CmdletBinding()]
    param(
        <#define add DNS rec param
        [Parameter(Mandatory)]
        [string]$add,#>

        #define hostname
        [Parameter(Mandatory)]
        [string]$newhost,

        #define IP
        [Parameter(Mandatory)]
        [string]$newIP,

        #define which zone to add recs to
        [Parameter(Mandatory)]
        [string]$zone

     )  
              
        # do some DNS things! 
        try  { Add-DnsServerResourceRecordA -ZoneName $zone -Name $newhost -IPv4Address $newIP

        }
        
        catch {

        #inform the user that this failed (likely trying to add a record to a non-existent zone)
        write-host `n`n`n"INVALID INPUT FOR EITHER -ZONE, -NEWHOST, OR -NEWIP!`n`nCHECK SYNTAX AND TRY AGAIN"`n`n`n -ForegroundColor Magenta
        #print the actual error text ...(come back to this later, need to print just the first sentence or so)
        $error[0]
        
        break

        }

        # hit next line if TRY is success...? or do I need to add "break/continue" statements? -yep... added "break"
        Write-Host `n`n"DNS RECORDS UPDATED SUCCESSFULLY!!"`n`n -ForegroundColor Cyan 

}
  




