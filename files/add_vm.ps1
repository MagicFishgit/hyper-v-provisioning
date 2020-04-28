#####add_vm####
###Purpose of this script is to create a VM in Windows Hyper-V when called and setting the desired paramaters 
###for the Virtual Machine. Default values apply if no paramater switch is given to ensure creation of a
###successful VM. Note: The script assumes that you already have a prebuilt operating .VHDX file ready.
####Created 2020/27/04####

#Declare Switch Paramaters#
param(
  [string]$vmName = "DefaultVMName",
  [string]$vmPath = "C:\ProgramData\Microsoft\Windows\Hyper-V\",
  [int16]$vmGen = 2,
  [string]$memStart = "1GB",
  [string]$vmSwitch = "vmvirtualswitch",
  [string]$vmSwitchName = "AutoVM Network Adapter 1",
  [string]$vmHDDName = "HDD.vhdx",  
  [string]$vmOSName = "OS.vhdx",
  [string]$prebVHDX = "test"
)
##End Declaration##

## TODO: Add some logic to check if prebuilt vhdx exists or passed argument is not null since it is required.##

##Convert string to Expression##
$memStart = Invoke-Expression $memStart
####Create the VM and Define startup paramaters and Generation. Specified -NoVHD because it is mounted later.###
New-VM -Name $vmName -Path "$vmPath" -NoVHD -Generation $vmGen -SwitchName $vmSwitch

####Configure most of the common VM settings here.####
Set-VM -Name $vmName -ProcessorCount 4 -DynamicMemory -MemoryMinimumBytes 1GB -MemoryStartupBytes $memStart -MemoryMaximumBytes 64GB -AutomaticStartAction Start -AutomaticStartDelay 1 -AutomaticStopAction Shutdown

####Create Virtual Hard Disk directory. Needed for easier directory consistency.###
New-Item -Path "$vmPath\$vmName\Virtual Hard Disks" -ItemType directory

####Copy Selected VM VHDX From VM directory to New VM VHDX directory.####
Copy-Item -Path C:\AutoVM\VHDX\UbuntuServer.vhdx -Destination "$vmPath\$vmName\Virtual Hard Disks\$vmOSName"
##todo:dont forget to add path var for preconfig vhdx##
####ADD preconfigured VHDX to new VM####
Add-VMHardDiskDrive -VMName $vmName -Path "$vmPath\$vmName\Virtual Hard Disks\$vmOSName"
$OsVirtualDrive = Get-VMHardDiskDrive -VMName $vmName -ControllerNumber 0

####Set preconfigured VHDX as boot device and disable secure boot.####
Set-VMFirmware -VMName $vmName -FirstBootDevice $OsVirtualDrive -EnableSecureBoot Off

####Create Aditional VHDX for storage or whatever you want. Dynamic.####
New-VHD -Path "$vmPath\$vmName\Virtual Hard Disks\$vmHDDName" -SizeBytes 3MB -Dynamic

####Attach the New VHDX####
Add-VMHardDiskDrive -VMName $vmName -Path "$vmPath\$vmName\Virtual Hard Disks\$vmHDDName"

####Add Network Adapter and any other network related settings here.####
Add-VMNetworkAdapter -VMName $vmName -SwitchName vmvirtualswitch -Name $vmSwitchName

####Read it.####
Start-VM -Name $vmName