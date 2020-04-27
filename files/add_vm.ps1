#####add_vm##########################################################################################################################
####Purpose of this script is to create a VM in Windows Hyper-V when called. Everything is static at the moment but when completed###
###you should be able to set any common states you want the VM to have by passing the script arguments. For now make sure you set up#
##directories as they appear in the script until it is made more dynamic.############################################################
#Created 2020/27/04##################################################################################################################

####Create the VM and Define startup paramaters and Generation. Specified -NoVHD because it is mounted later.###
New-VM -Name test01 -Path C:\AutoVM\vm\ -NoVHD -Generation 2 -MemoryStartupBytes 1GB -SwitchName vmvirtualswitch

####Configure most of the normal VM settings here.####
Set-VM -Name test01 -ProcessorCount 4 -DynamicMemory -MemoryMinimumBytes 1GB -MemoryStartupBytes 1GB -MemoryMaximumBytes 4GB -AutomaticStartAction Start -AutomaticStartDelay 1 -AutomaticStopAction Shutdown

####Create Virtual Hard Disk directory. Needed for easier directory consistency.###
New-Item -Path "C:\AutoVM\vm\test01\Virtual Hard Disks" -ItemType directory

####Copy Selected VM VHDX From VM directory to New VM VHDX directory.####
Copy-Item -Path C:\AutoVM\VHDX\UbuntuServer.vhdx -Destination "C:\AutoVM\vm\test01\Virtual Hard Disks\OS.vhdx"

####ADD preconfigured VHDX to new VM####
Add-VMHardDiskDrive -VMName test01 -Path "C:\AutoVM\vm\test01\Virtual Hard Disks\OS.vhdx"
$OsVirtualDrive = Get-VMHardDiskDrive -VMName test01 -ControllerNumber 0

####Set preconfigured VHDX as boot device and disable secure boot.####
Set-VMFirmware -VMName test01 -FirstBootDevice $OsVirtualDrive -EnableSecureBoot Off

####Create Aditional VHDX for storage or whatever you want. Dynamic.####
New-VHD -Path "C:\AutoVM\vm\test01\Virtual Hard Disks\Data.vhdx" -SizeBytes 3MB -Dynamic

####Attach the New VHDX####
Add-VMHardDiskDrive -VMName test01 -Path "C:\AutoVM\vm\test01\Virtual Hard Disks\Data.vhdx"

####Add Network Adapter and any other network related settings here.####
Add-VMNetworkAdapter -VMName test01 -SwitchName vmvirtualswitch -Name "AutoVM Network Adapter 1"

####Read it.####
Start-VM -Name test01