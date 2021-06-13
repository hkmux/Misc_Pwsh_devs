#####################################################################
#
#   .synopsis:
#      quick/dirty script to setup your dns entries on an Windows Server guest machine (VM);
#        point your VCSA installer to this DNS server for name resolution 
#
#    .conditions:
#        this machine should have the DNS feature installed 
#         
#    .execution 
#        call this script by navigating to the directory where the file is 
#         stored and enter ".\DNS-RECORD-SETUP.ps1" without entering the "s
#
#     .code snippet junkyard:
#           <#  
#            $thisname = whoami
#            $sep = "\"
#            $thatname = $thisname.split($sep)
#            $DNSHost = $thatname[0]
#           #>
            <#
            .variables: 
                $PNet  #primary network address
                $PMask  #netmask for the primary network
                $VCSA  #hostname of the vCenter Server Appliance
                $VCIP  #IP of the vCenter Server Appliance
                $VCDomain  #FQDN for the ESXi/vCenter management network nodes 
                $DNSHost  #hostname of this machine (DNS server)
                $DNSip  #IP addr of this machine (DNS server)
     
                EXAMPLES: 
                $PNet = 192.168.1.0
                $PMask  /24
                $VCSA = 'vcsa'
                $VCIP = [string]"192.168.1.254" 
                $VCDomain = [string]'shopname.test' 
                $DNSHost = [string]'dns-svr-core' 
                $DNSip = [string]"192.168.1.253"  
                #>
#
# $DH
#####################################################################



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
  THIS SCRIPT WAS DESIGNED TO BUILD DNS SETTINGS - PRE-INSTALLATION OF VCSA,`n
   BUT CAN BE RUN AS MANY TIMES AS NEEDED TO BUILD DNS PRIMARY ZONES ON `n
                ANY MACHINE CONFIGURED AS A DNS SERVER`n 
##############################################################################`n
" -ForegroundColor Yellow 
Write-Host `n" Press any key to continue..."`n -ForegroundColor DarkCyan
Read-Host
cls 
# announce first step
Write-Host `n`n`n"FIRST STEP: COLLECT ENVIRONMENT INFORMATION" -ForegroundColor Yellow -NoNewline
sleep 1
Write-Host " ." -NoNewline -ForegroundColor Yellow
sleep 1
Write-Host "." -NoNewline -ForegroundColor Yellow
sleep 1
Write-Host "." -NoNewline -ForegroundColor Yellow
sleep 1
Write-Host "." 
sleep 2

###############################################
#assumed .variables (later on, ask user if correct, just to be 4sho)
###############################################
# DNS Hostname
$DNSHost = $env:COMPUTERNAME
# DNS IP --note: the [0] gets the ipv4 addr, but [1] would get the ipv6 addr since link-local ipv6 is the 2nd in the array.
$DNSip = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration).IPAddress[0]

###############################################    
#collect .variables
###############################################

### primary netw  
Write-Host `n`n`n`n`n"ENTER THE NETWORK ADDRESS FOR THE " -Foregroundcolor DarkCyan -NoNewline  
write-host "ESXI/VCENTER MANAGEMENT NETWORK " -nonewline -ForegroundColor Cyan
write-host ", THEN PRESS ENTER:" -ForegroundColor DarkCyan ; Write-host `n"!! NOTE: MUST BE A" -foregroundcolor DarkCyan -NoNewline
Write-Host " *NETWORK ID*" -foregroundcolor Red -nonewline ; Write-Host ", NOT IP ADDRESS, OR THIS SCRIPT WILL FAIL !!"`n -ForegroundColor DarkCyan
$PNet=Read-Host

### netmask for the primary network
cls
Write-Host `n"ENTER THE NETWORK PREFIX IN SLASH NOTATION FOR THE ESXI/VCENTER SERVER MANAGEMENT NETWORK (INCLUDE THE "/"), `
THEN PRESS ENTER:" -ForegroundColor DarkCyan 
Write-host `n'[EXAMPLE: TYPE " ' -ForegroundColor DarkCyan -NoNewline ; Write-Host '/24' -ForegroundColor Cyan -NoNewline 
Write-Host ' " FOR A 24 BIT SUBNET MASK]'`n -ForegroundColor DarkCyan 
$PMask=Read-Host

### vcsa host
#cls
Write-Host `n"ENTER THE HOSTNAME FOR THE VCENTER SERVER APPLIANCE," -ForegroundColor DarkCyan -NoNewline
Write-Host " NO SPACES, SPECIAL CHARACTERS, OR UNDERSCORES" -ForegroundColor Red -NoNewline
Write-Host ", THEN PRESS ENTER: "`n -ForegroundColor DarkCyan 
$VCSA=Read-Host

### vcsa ip
#cls
Write-Host `n"ENTER THE IP ADDRESS FOR THE VCENTER SERVER APPLIANCE ` 
 - THE IP MUST BE WITHIN THE PRIMARY NETWORK DEFINED IN THE PREVIOUS STEPS ($PNet$PMask), THEN PRESS ENTER:" -ForegroundColor DarkCyan 
$VCIP=Read-Host

### vc domain
#cls
Write-Host `n"WHAT IS THE DOMAIN FOR THE VCENTER MANAGEMENT NETWORK? [EXAMPLE: j6.mgmtnetwork] -- TYPE THE DOMAIN NAME AND PRESS ENTER:" -ForegroundColor DarkCyan 
$VCDomain=Read-Host

### dns server hostname
#cls
    <# temp for testing this block:
         $DNSHost = $env:COMPUTERNAME
     #>
Write-Host `n"Is the name of the DNS Server (this machine)" -nonewline -ForegroundColor DarkCyan 
Write-Host "  $DNSHost" -ForegroundColor Magenta -nonewline
Write-Host " ??  [YES/NO]"`n -ForegroundColor DarkCyan 
$dnsinput = Read-Host  #determine if the read hostname is accurate
#cls
    if ($dnsinput -like "n*") {    
    Write-Host `n"ENTER THE HOSTNAME (COMPUTER NAME) OF THE DNS SERVER (THIS MACHINE), THEN PRESS ENTER:"`n -ForegroundColor DarkCyan 
    $DNSHost=Read-Host
    }  
    else {}  # <--- need this to close the action??

 #Write-Host " execution test 1 "
sleep 3

### dns server ip addr
#cls 
 <#temp for testing this block:
 $DNSip = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration).IPAddress[1]
 #>
Write-Host `n"Is the IP of the DNS Server (this machine)" -nonewline -ForegroundColor DarkCyan 
Write-Host "  $DNSip" -ForegroundColor Magenta -nonewline
Write-Host " ??   [YES/NO]"`n -ForegroundColor DarkCyan 
$dnsIPinput = Read-Host  #determine if the read hostname is accurate
#cls
    if ($dnsIPinput -like "n*") {    
    Write-Host `n"ENTER THE IP ADDRESS YOU WOULD LIKE TO BIND THE DNS SERVER (THIS MACHINE) TO THEN PRESS ENTER:" -ForegroundColor DarkCyan
    $DNSip=Read-Host
    }  
    else {}

 #Write-Host "execution test 2"
sleep 2

###############################################    
#execute DNS record additions w/ variables
###############################################
cls
Write-Host `n`n`n`n`n"CONFIGURING DNS RECORDS"`n`n -ForegroundColor Yellow
sleep 2

### Establish PRIMARY ZONE file for A records
Add-DnsServerPrimaryZone -Name $VCDomain -ZoneFile "$VCDomain.dns" -DynamicUpdate None

### Establish PRIMARY ZONE file for PTR records
<# 
   # need to write regex statement to get the $pnet in reverse for PTR REC... come back to this later 
#PTR RECORDS
#add-dnsserverprimaryzone -networkid $PNet$Pmask -zonefile "x.x.x.in-addr.arpa.dns"
#>

### Add A Records
# VCSA 
Add-DnsServerResourceRecordA -ZoneName $VCDomain -Name $VCSA -IPV4Address $VCIP -Verbose
# DNS HOST
Add-DnsServerResourceRecordA -ZoneName $VCDomain -Name $DNSHost -IPV4Address $DNSip -Verbose

### Add PTR Records
# later (regex statements for x.x.x.in-addr.arpa.dns)

 <# internal tests when not on Server Core machine:
 ping $DNSHost
    #note: when pinging $DNSHost it looks @ ipv6... ".gettype()" returns "[string]", so i dont get it... 
 ping $DNSip
 nslookup $DNSHost
 #>

# inform user of records and print out the current DNS DB
cls
Write-Host `n`n`n`n`n"RECORDS HAVE BEEN ADDED TO THIS DNS SERVER FOR " -NoNewline -ForegroundColor yellow `
; Write-Host "$dnshost" -ForegroundColor cyan -NoNewline ; write-host " AND " -ForegroundColor Yellow -NoNewline ` 
write-host "$vcsa"`n`n`n`n -ForegroundColor cyan
sleep 3
cls
write-host `n`n`n`n`n"HERE ARE THE RECORDS YOU DEFINED FOR THE $VCDomain :"`n`n`n`n -ForegroundColor Yellow
sleep 3

$dnsout = Get-DnsServerResourceRecord -ZoneName $VCDomain | ?{$_.hostname -notlike "@"}  
get-dnsserverzone -name $vcdomain ; $dnsout | ft
Write-Host `n`n"Press Enter to Continue"`n`n -ForegroundColor DarkCyan
Read-Host


###############################################
# Gather IPs for other Hosts to add to DNS records
###############################################

# inform user that this section is complete and we can now ask for any addtl IPs to add (for convenience)
cls
Write-Host `n`n`n`n`n"DNS RECORDS FOR VCENTER SERVER APPLIANCE " -nonewline -foregroundcolor Yellow 
write-host "COMPLETE!"`n`n`n`n -ForegroundColor Green
write-host "NEXT STEP: ADD IPs FOR OTHER MACHINES OR ESXi HOSTS"  -ForegroundColor Yellow -NoNewline
sleep 1 ; Write-Host " ." -NoNewline -f yellow ; sleep 1 ; Write-Host "." -NoNewline -f yellow 
sleep 1 ; Write-Host "." -NoNewline -F yellow ; sleep 1 ; Write-Host "."`n`n`n -f yellow
sleep 2

### Establish if user wants to add any ESXI hosts to the DNS DB
cls
Write-Host ``n`n`n`n`n"WOULD YOU LIKE TO ADD DNS RECORDS FOR OTHER MACHINES OR ESXI HOSTs?`n`n`n [YES/NO]" -ForegroundColor DarkCyan
$firstinput = Read-Host
    if ($firstinput -like "y*") {
        cls
        Write-Host `n`n"USER REQUESTED ADDITIONAL DNS RECORD CREATION"`n`n -ForegroundColor Yellow
        #receive hostname input
        Write-Host `n`n"WHAT IS THE" -F DarkCyan -NoNewline ; Write-Host " HOSTNAME" -f Cyan -NoNewline
        Write-Host " OF THE FIRST MACHINE OR ESXI HOST YOU WOULD LIKE TO CREATE A DNS RECORD FOR?"`n`n -ForegroundColor DarkCyan
        $firstHOSTNAME=Read-Host
        #receive ip input
         Write-Host `n`n"WHAT IS THE" -F DarkCyan -NoNewline ; Write-Host " IP ADDRESS" -f Cyan -NoNewline
        Write-Host " OF THE FIRST MACHINE OR ESXI HOST YOU WOULD LIKE TO CREATE A DNS RECORD FOR?"`n`n -ForegroundColor DarkCyan
        $firstIP=Read-Host
        #add the record in DNS Zone File
        Add-DnsServerResourceRecordA -ZoneName $VCDomain -Name $firstHOSTNAME -IPV4Address $firstIP
        #report DNS addition to user
        Write-Host `n`n`n"RECORD ADDED FOR $firstHOSTNAME @ $firstIP!"`n`n`n -ForegroundColor Green ; sleep 2
            
            Write-Host `n`n`n"WOULD YOU LIKE TO ADD MORE HOSTS TO THE DNS RECORDS?`n`n[YES/NO]" -ForegroundColor DarkCyan
            #receive next input and determine whether to begin loop
            $LOOPinput = read-host
                if ($LOOPinput -like "n*") { 
                #lets cleanup and rollout then... 
                cls ; Write-Host `n`n`n`n`n"HOST DNS RECORDS COMPLETE! `n`nQUITTING" -ForegroundColor Green -NoNewline ;`
                 sleep 1 ; Write-Host "." -f Green -NoNewline ;  Write-Host "." -f Green -NoNewline ;  Write-Host "." -f Green ;` 
                 sleep 1
                # last check in the loop for code testing
 #Write-Host `n`n`n`n" END OF *NO ADD HOSTS* ELSE STATEMENT"`n`n -ForegroundColor Magenta ; sleep 2
                }
                
                else {
                    ### begin loop to gather IPs and Hostnames
                    do {
                        #receive hostname input
                        Write-Host `n`n"WHAT IS THE" -F DarkCyan -NoNewline ; Write-Host " HOSTNAME" -f Cyan -NoNewline
                        Write-Host " OF THE NEXT MACHINE OR ESXI HOST YOU WOULD LIKE TO CREATE A DNS RECORD FOR?"`n`n -ForegroundColor DarkCyan
                        $nextHOST=Read-Host
                        #receive ip input
                         Write-Host `n`n"WHAT IS THE" -F DarkCyan -NoNewline ; Write-Host " IP ADDRESS" -f Cyan -NoNewline
                        Write-Host " OF THE NEXT MACHINE OR ESXI HOST YOU WOULD LIKE TO CREATE A DNS RECORD FOR?"`n`n -ForegroundColor DarkCyan
                        $nextIP=Read-Host
                        #add the record in DNS Zone File
                        Add-DnsServerResourceRecordA -ZoneName $VCDomain -Name $nextHOST -IPV4Address $nextIP
                        #report DNS addition to user
                        Write-Host `n`n`n"RECORD ADDED FOR $nextHOST @ $nextIP!"`n`n`n -ForegroundColor Green ; sleep 2
 #write-host `n`n`n"the adds are: $nextHOST and $nextIP..."`n`n`n`n ## quick test 

                        #tricky part... looping again:
                        write-host `n`n`n"WOULD YOU LIKE TO ADD MORE HOSTS TO THE DNS RECORDS?`n`n[YES/NO]" -ForegroundColor DarkCyan
                        $secondaryLOOPINPUT=Read-Host
                    } until ($secondaryLOOPINPUT -like "n*")
                    #once user declares no more additions, inform user of completion and close out
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
