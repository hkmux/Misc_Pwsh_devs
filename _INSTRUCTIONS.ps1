
write-host "`n
################################################################
                DNS BUILD INSTRUCTIONS
################################################################`n" -foregroundcolor yellow

Write-Host "
The files in this folder will check to see if the DNS Role is installed, and
if not, install it, then create a Primary DNS Zone with as many A Records as 
needed. `n
Before running this script, take note that this was intended to build DNS
on a small, < 40GB, Windows Server Core 2016 VM for the purposes of installing
the vCenter Server Appliance (VCSA) on ESXi 6.7 and later versions (7.0+).
The environment should have at least one ESXi v6.7(+) Host with Management Network
configurations already set. The VM with Server Core 2016 (likely, the machine
this is being read on) should be deployed on the ESXi Host that will contain
the VCSA. Once all the scripts have been run against the intended DNS server, 
then DNS will be running and the VCSA .iso can be mounted on a web client 
(management PC or any laptop/machine with network access to the ESXi Host and VM), 
and then the UI installer executable can be run from within the mounted .iso disk. 
A concise list of conditions and steps is given in the next pages of instructions. 

The specific use case for developing these scripts was to suport the initial deployment 
of VCSA in an isolated environemtn. However, they can used for the simple purpose 
of installing DNS Role, creating a Primary Zone file (xyz.dns), and then building 
some manual entries/records in the zone. 
These scripts are idempotent and can be run or re-run as many times as needed. 
Running the Install_DNS_Roles_and_Features script will do nothing once DNS Roles 
are installed. 
The Build_DNS_Zone will build a DNS Forward Lookup Zone intended
for use in VCSA deployment, but can be re-run ~ times to automate the build of
multiple Forward Lookup Zones with as many entries as the user requires. 
" -ForegroundColor Yellow

Write-Host "`nPress [ENTER] for next instruction page" -ForegroundColor Gray
read-host
cls
Write-Host "`n


CONDITIONS   
The deployment environment should meet the following conditions:
    1) Physical
        a. Baremetal server  
        b. PC (Laptop, desktop, etc)
        c. Layer 2 (L2) switch 
        d. vCenter Server Install disc with VCSA ISO

    2) Preparation
        a. ESXi v6.7 or later should be installed on the Baremetal server
        b. The Management Network settings should be configured on ESXi
        c. The IPv4 or IPv6 settings should be set on the laptop
        d. Both devices should be plugged into the L2 switch 
        e. Network connectivity should be successful between ESXi Host and PC
        f. The vCenter Server Install Disc should be mounted on PC
        z. NOTE: this can be done without a switch if the PC is connected
         to the ESXi Host via network cable and both NICs are in the same subnet! 

" -ForegroundColor Yellow

Write-Host "`nPress [ENTER] for next instruction page..." -ForegroundColor Gray
Read-Host
cls
Write-Host "`n


STEPS
Follow these steps to complete the DNS configuration: 
    1) Establish connectivity between PC and ESXi Host
    2) Browse to the UI of the ESXi Host from the PC
    3) Build a DataStore if one is not already built/configured
    4) Deploy Windows Server 2016 Core VM from OVF template
    5) Ensure Server Core VM and PC are connected to the vSwitch
    6) Open a web console session to the Server Core VM" -ForegroundColor Yellow
write-host "`n*** if you are reading this on the Server Core VM, then the above steps have already been completed ***" -ForegroundColor white 
write-host "
    7) Read the instructions  :)
    8) Run the Install_DNS_Roles_and_Features.ps1 script and follow the prompts
    9) Run the Build_DNS_Zones.ps1 script and follow the prompts
        9a) Create/configure the Primary Zone name
        9b) Create records for VCSA and ESXi by hostname/IP 
        9c) Create additional record for the PC (optional, but useful)
        9d) Create additional records for other ESXi Hosts or machines
        -- take care to configure hosts in the same subnet unless you have
                a Layer three device or other routing solution in your architecture. 
    10) Test DNS resolution from all devices (ensuring DNS clients are pointed at ServerCore VM IP)
    11) From the PC, launch the UI Installer application from the directory in the mounted ISO
        11a) Follow the install Wizard, ensuring the hostnames/IP and DNS information matches
                what you configured in the Build_DNS_Zone script


" -ForegroundColor Yellow
Write-Host "`n Press [ENTER] when done..." -ForegroundColor Gray
Read-Host
