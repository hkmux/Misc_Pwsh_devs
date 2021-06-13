#####################################################################
#  !!!!  CURRENTLY BROKEN  !!!!
#       Need to address custom function "J3-removednsrecord" - not working
#           the function runs, but is not removing the record, and yet reports success
#
#   .synopsis:
#      quick/dirty script to REMOVE DNS entries from an existing 
#        Forward Lookup DNS Zone (<zonename>.dns)     
#
#    .conditions:
#        this machine should have the DNS feature installed 
#            and have multiple records in at least one DNS Zone
#         
#    .execution 
#        call this script by navigating to the directory where the file is 
#         stored and enter ".\DNS-RECORD-SETUP.ps1" without entering the "s
#
#     .code snippet junkyard:
           <#  
            $thisname = whoami
            $sep = "\"
            $thatname = $thisname.split($sep)
            $DNSHost = $thatname[0]
           #>
            <#
            $IndivZoneprint = @()
            $zonecollection = Get-DnsServerZone | ?{$_.zonename -notlike "@"}
            
            foreach($IndivZone in $zonecollection) {
                $IndivZone.zonename += $IndivZoneprintg
            }
            $IndivZoneprint #>
#
#      .function(s):
#      
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
#
#
# $DH
#####################################################################

###############################################
#assumed .variables (later on, ask user if correct, just to be 4sho)
###############################################

# currently configured zone (filter irrelevant zones)
$currentzones = Get-DnsServerZone | ?{$_.zonename -notlike "TrustAnchors" -and $_.isautocreated -eq $false}

###############################################
#inform user of purpose and first step
###############################################
cls
write-Host `n`n`n`n`n"
#############################################################################`n  
                            JCSE J3 ENGINEERING `n 
#############################################################################"`n`n`n`n -ForegroundColor Yellow
sleep 1
Write-Host `n`n"
##############################################################################`n
        THIS SCRIPT IS SPECIFICALLY FOR REMOVING DNS RECORDS FROM 
            AN ALREADY EXISTING/BUILT DNS FORWARD LOOKUP ZONE.`n 
        EXAMPLE:
            The Local DNS Server (this machine) has a Zone file for J6.BDE.NET, 
            and that [Forward Lookup] Zone has two records for the
            same Domain Controller - DC1.J6.BDE.NET; causing a DNS resolution conflict.
            
            The first record lists DC1 @ 10.1.1.1
            
            but the second record lists DC1 @ 5.5.5.5 
            
            The correct DC IP is 5.5.5.5, and the 10.1.1.1 record must be 
            removed. 
            
            To do so, use the following prompts to define the Hostname (DC1) 
            and the IP to remove (10.1.1.1). 
            
            The record will be removed and you will be presented with the 
            option (YES/NO) of removing additional records.

##############################################################################`n
" -ForegroundColor Yellow 
Write-Host `n" Press ENTER to continue..."`n -ForegroundColor GRAY
Read-Host
cls 
# announce first step
Write-Host `n`n`n"FIRST STEP: DISPLAY CURRENT DNS ZONES ON LOCAL MACHINE" -ForegroundColor Yellow -NoNewline
sleep 1
Write-Host " ." -NoNewline -ForegroundColor Yellow
sleep 1
Write-Host "." -NoNewline -ForegroundColor Yellow
sleep 1
Write-Host "." -NoNewline -ForegroundColor Yellow
sleep 1
Write-Host "." 
write-host `n" HERE ARE ALL THE ZONES ON THIS DNS SERVER:`n" -ForegroundColor Cyan 
$currentzones | ft zonename, zonetype, isreverselookupzone
write-host "Press ENTER to continue..." -ForegroundColor Gray
read-host

###############################################    
#collect .variables
###############################################

write-host "NEXT STEP: COLLECT INFORMATION FOR RECORD(S) TO BE REMOVED..." -foregroundcolor yellow

### Zone
Write-Host `n"WHAT IS THE " -NoNewline -ForegroundColor darkCyan
WRITE-HOST "ZONE " -NoNewline -ForegroundColor Cyan 
write-host "YOU WANT TO REMOVE RECORDS FROM?`n" -Foregroundcolor DarkCyan 
$rzone=Read-Host
cls
write-host "`n`nGOT IT!`n`n`n HERE ARE THE RECORDS IN THAT ZONE:" -ForegroundColor DarkCyan
#display the records in that zone 
Get-DnsServerResourceRecord -ZoneName $rzone | ?{$_.hostname -notlike "@"} | ft

### host 
Write-Host `n"ENTER THE NAME OF THE" -NoNewline -ForegroundColor DarkCyan 
Write-Host " HOST" -NoNewline -ForegroundColor Cyan
WRITE-host " YOU WANT REMOVE THE RECORD FOR, THEN PRESS ENTER: "`n -ForegroundColor DarkCyan 
$rhost=Read-Host

### record type
Write-Host "WHAT IS THE RECORD " -nonewline -ForegroundColor DarkCyan
write-host "TYPE " -NoNewline -foregroundcolor Cyan 
write-host "OF THE RECORD YOU WANT TO REMOVE? [A, NS, SOA]:" -ForegroundColor DarkCyan 
$RemRecType=Read-Host

### ip
Write-Host `n"WHAT IS THE" -NoNewline -ForegroundColor DarkCyan 
write-host " IP ADDRESS " -NoNewline -foregroundcolor Cyan 
write-host "OF THE HOST RECORD YOU WANT TO REMOVE?" -ForegroundColor DarkCyan 
$rIP=Read-Host

##############################################
# confirm with user and take action
##############################################
cls
write-host "ARE YOU SURE YOU WANT TO REMOVE THE" -NoNewline -ForegroundColor Magenta
write-host " $RemRecType " -NoNewline -ForegroundColor Cyan 
write-host "RECORD FOR" -NoNewline -ForegroundColor Magenta 
write-host " $rhost " -NoNewline -ForegroundColor Cyan 
write-host "@" -NoNewline -ForegroundColor Magenta 
write-host " $rip " -NoNewline -ForegroundColor Cyan 
write-host "IN THE" -NoNewline -ForegroundColor Magenta
write-host " $rzone " -NoNewline -ForegroundColor Cyan 
write-host "[YES/NO]?" -ForegroundColor Magenta
    # grab input and make a decision to quit or not:
    $userremoveinput=read-host
     
   
###############################################
# IF statement, we will or we wont 
##############################################
   
    if ($userremoveinput -like "y*") { #... then remove that rec!   
    write-host "NEXT STEP: REMOVE RECORD! " -ForegroundColor Yellow 
    J3-RemoveDNSRecord -rzone $rzone -rhost $rhost -remRecType $RemRecType -rIP $rIP
    #note: success statement and a display of updated records is built into the 
    # custom "J3-removednsrecord" function, no need to do it here
    } 

    #otherwise, bail out before making changes 
    else {    
    Write-Host `n"OKAY.`n NO RECORDS WILL BE REMOVED. THIS PROCESS WILL TERMINATE..."`n -ForegroundColor DarkCyan 
    Write-Host `n"Press Enter to Continue..." -ForegroundColor Gray
    Read-Host
    }  

#Write-Host " execution test 1 "
sleep 1


###############################################
# Gather info for other records
###############################################

# inform user that this section is complete and we can now ask for any addtl IPs to remove (for convenience)
cls
Write-Host `n`n`n`n`n"DNS RECORD REMOVAL " -nonewline -foregroundcolor Yellow 
write-host "COMPLETE!"`n`n`n`n -ForegroundColor Green
write-host "NEXT STEP: DETERMINE IF ADDITIONAL RECORDS NEED TO BE REMOVED"  -ForegroundColor Yellow -NoNewline
sleep 1 ; Write-Host " ." -NoNewline -f yellow ; sleep 1 ; Write-Host "." -NoNewline -f yellow 
sleep 1 ; Write-Host "." -NoNewline -F yellow ; sleep 1 ; Write-Host "."`n`n`n -f yellow
sleep 2

#---------------------------------------------------------------------------------------#
#   END OF FIRST RECORD REMOVAL ;; ROUND 2 W/ "IF" STATEMENTS AND LOOPS 
#--------------------------------------------------------------------------------------#


### Establish if user wants to remove addtl recs
cls

do {  

Write-Host ``n`n`n`n`n"WOULD YOU LIKE TO REMOVE ANY OTHER DNS RECORDS? [YES/NO]" -ForegroundColor DarkCyan
$LOOPINPUT = Read-Host
    if ($LOOPINPUT -like "y*") {
        cls
        Write-Host `n`n"USER REQUESTED ADDITIONAL DNS RECORD REMOVAL"`n`n -ForegroundColor Yellow
            #display zones to the user again: 
            write-host `n" HERE ARE THE ZONES ON THIS DNS SERVER:`n" -ForegroundColor Cyan 
            $currentzones | ft zonename, zonetype, isreverselookupzone
            write-host "Press ENTER to continue..." -ForegroundColor Gray
            read-host

            ###############################################
            #collect .variables (RD 2)
            ###############################################

            write-host "NEXT STEP: COLLECT INFORMATION FOR RECORD(S) TO BE REMOVED..." -foregroundcolor yelloW
            ### Zone
            Write-Host `n"WHAT IS THE " -NoNewline -ForegroundColor darkCyan
            WRITE-HOST "ZONE " -NoNewline -ForegroundColor Cyan 
            write-host "YOU WANT TO REMOVE THE NEXT RECORDS FROM?`n" -Foregroundcolor DarkCyan 
            $rzone=Read-Host
            cls
            write-host "`n`nGOT IT!`n`n`n HERE ARE THE RECORDS IN THAT ZONE:" -ForegroundColor DarkCyan
            #display the records in that zone 
            Get-DnsServerResourceRecord -ZoneName $rzone | ?{$_.hostname -notlike "@"} | ft

            ### host 
            Write-Host `n"ENTER THE NAME OF THE NEXT" -NoNewline -ForegroundColor DarkCyan 
            Write-Host " HOST" -NoNewline -ForegroundColor Cyan
            WRITE-host " YOU WANT REMOVE THE RECORD FOR, THEN PRESS ENTER: "`n -ForegroundColor DarkCyan 
            $rhost=Read-Host

            ### record type
            Write-Host "WHAT IS THE RECORD " -nonewline -ForegroundColor DarkCyan
            write-host "TYPE " -NoNewline -foregroundcolor Cyan 
            write-host "OF THE NEXT RECORD YOU WANT TO REMOVE? [A, NS, SOA]:" -ForegroundColor DarkCyan 
            $RemRecType=Read-Host

            ### ip
            Write-Host `n"WHAT IS THE" -NoNewline -ForegroundColor DarkCyan 
            write-host " IP ADDRESS " -NoNewline -foregroundcolor Cyan 
            write-host "OF THE HOST RECORD YOU WANT TO REMOVE?" -ForegroundColor DarkCyan 
            $rIP=Read-Host

            ##############################################
            # confirm with user and take action (RD 2) 
            ##############################################
            cls
            write-host "ARE YOU SURE YOU WANT TO REMOVE THE" -NoNewline -ForegroundColor Magenta
            write-host " $RemRecType " -NoNewline -ForegroundColor Cyan 
            write-host "RECORD FOR" -NoNewline -ForegroundColor Magenta 
            write-host " $rhost " -NoNewline -ForegroundColor Cyan 
            write-host "@" -NoNewline -ForegroundColor Magenta 
            write-host " $rip " -NoNewline -ForegroundColor Cyan 
            write-host "IN THE" -NoNewline -ForegroundColor Magenta
            write-host " $rzone " -NoNewline -ForegroundColor Cyan 
            write-host "[YES/NO]?" -ForegroundColor Magenta
                # grab input and make a decision to quit or not:
                $userremoveinput=read-host
            } #end of IF

            ###############################################
            # IF statement, we will or we wont (RD 2)
            ##############################################
            
                if ($userremoveinput -like "y*") { #... then remove that rec!   
                write-host "NEXT STEP: REMOVE RECORD! " -ForegroundColor Yellow 
                J3-RemoveDNSRecord -rzone $rzone -rhost $rhost -remRecType $RemRecType -rIP $rIP
                #note: success statement and a display of updated records is built into the 
                # custom "J3-removednsrecord" function, no need to do it here
                } 

                #otherwise, bail out before making changes 
                else {    
                Write-Host `n"OKAY.`n NO RECORDS FROM THE $rzone REMOVED..."`n -ForegroundColor DarkCyan 
                Write-Host `n"Press Enter to Continue..." -ForegroundColor Gray
                Read-Host
                }  

               #cls
               #Write-Host "DO YOU WANT TO REMOVE ADDITIONAL DNS RECORDS FROM THIS HOST?" -ForegroundColor DarkCyan
                 #$LOOPINPUT=Read-Host
                    } until ($LOOPINPUT -like "n*") 
         #end of DO LOOP



         # insert final out




     








# CODE JUNKYARD BELOW  -- will deal with Final Out after fixing the code above

<#

                    cls
                    Write-Host `n`n`n`n`n"NO FURTHER HOSTS TO ADD. HOST DNS RECORDS COMPLETE! `n`nQUITTING" -ForegroundColor Green -NoNewline
                    sleep 1 ; Write-Host "." -f Green -NoNewline ; sleep 1 ; Write-Host "." -f Green -NoNewline ; sleep 1 
                    Write-Host "." -f Green ; sleep 1

 #Write-Host `n`n`n`n" END OF *DO UNTIL LOOP* STATEMENT"`n`n -ForegroundColor darkMagenta ; sleep 2
                }
    }
    else {
    cls
    Write-Host `n`n`n`n`n"NO HOSTS TO ADD. `n`nQUITTING" -ForegroundColor Green -NoNewline
    sleep 1 ; Write-Host "." -f Green -NoNewline ; sleep 1 ;  Write-Host "." -f Green -NoNewline ; sleep 1 
    Write-Host "." -f Green ; sleep 1

 #Write-Host `n`n`n`n"  END OF *NO ADD HOSTS* ELSE STATEMENT"`n`n -ForegroundColor darkMagenta ; sleep 2
    
    }


###############################################
# FINAL OUT
###############################################
cls
write-host `n`n`n`n`n"HERE ARE THE RECORDS FOR THE FQDN YOU DEFINED: "`n`n`n`n -ForegroundColor Yellow
sleep 2

$dnsout = Get-DnsServerResourceRecord -ZoneName $VCDomain | ?{$_.hostname -notlike "@"}  
$dnsout
Write-Host `n`n"Press Enter to Quit"`n`n -ForegroundColor DarkCyan
Read-Host

Write-Host `n`n`n`n"DONE!   CHARLIE MIKE!!"`n`n`n -ForegroundColor Magenta
sleep 2
#>