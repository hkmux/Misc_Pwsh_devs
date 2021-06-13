#####################################################################
#
#   .synopsis:
#      steps for prepping Windows Core machine for remote management
#      for this task the client and host are a NON-domain-joined Server Core
#        machine, and a domain-joined server, respectively.  
#        host=gui / domain-joined host [management server]
#         client=ServerCore / non-domain-joined [managed machine]
#   
#    .note: 
#      this is NOT a script!
#        the USER/PASS/DOMAIN/HOSTNAMEs in this are just demonstrative.
#            .. replace with correct values when completing this task
#      in case this gets long, adding three #s for "sections" and 
#            five #s for individual tasks to be completed...so, search for 3 or 5 #s
#
# $DH
#####################################################################

### on remote Windows Server Core machine (client) 

##### enable posh remote
Enable-PSRemoting
##### enable wsman -- by domain for xtra security
Enable-WSManCredSSP -Role Client -DelegateComputer "*j3.testeng"
##### add entry in trusted hosts of wsman (allow the connecting device [host] by name)
Set-Item -Path WSMan:\localhost\client\trustedhosts -Value "192.168.11.*"  
    # ^ if IP (not FQDN) here, use IP to build PSSession
##### create cached credential for the client to connect to the host 
cmdkey /add:j3.testeng /user:sm3 /pass:sme!Q@W#E$R5t
##### configure DNS records on client to point at host ip/fqdn 
add-content C:\Windows\System32\drivers\etc\hosts -Value "192.168.11.200 j3ad1.j3.testeng"



### on  Server machine (host)

##### add entry in trusted hosts of wsman (allow the connecting device [host] by name)
Set-Item -Path WSMan:\localhost\client\trustedhosts -Value "*192.168.11.*"
    # ^ if IP (not FQDN) here, use IP to build PSSession
#####set credentials with cmdkey for remote machine
cmdkey /add:j3.testeng /user:sm3 /pass:sme!Q@W#E$R5t
##### configure DNS records on host to point at client ip/fqdn (( cant hurt! ))
add-content C:\Windows\System32\drivers\etc\hosts -Value "192.168.11.253 dns-svr-core"
##### build PSSession for xfer FROM host TO client
New-PSSession -computername 192.168.11.253 -name NewSession1
    # ^ use FQDN if thats how its defined in WSMAN Trusted Hosts
##### use ps session to transfer files TO client
$sessionvariable = get-pssession -Name NewSession1
copy-item x:\files -ToSession NewSession1 
    #or, FROM client TO host --> executed at the host PoSh terminal
    copy-item -FromSession NewSession1 -Path x:\client\files -Destination x:\host\files



### extra tips for server:

##### enable print sharing thru the FW
netsh advfirewall firewall set rule group="file and printer sharing" new enable=yes
##### change dir into the distant end to copy FROM client TO host
cd \\192.168.11.253\c$
    # copy files on client to host after cd'ing into dir
    copy *.ps1 \\192.168.11.200\c$\Users\xman\Documents


