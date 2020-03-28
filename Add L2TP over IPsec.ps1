
<#
.SYNOPSIS
  This script adding L2TP over IPsec VPN.
.DESCRIPTION
  With this Powershell Script, the addition of an L2TP over IPsec VPN can be automated.
.NOTES
  Created by  : T13nn3s
  Version     : 1.0.3 (11 December 2017)
  #>
 
# Checks if powershell is in Administrator mode, if not powershell will fix it  
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {     
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"  
  Start-Process powershell -Verb runAs -ArgumentList $arguments  
  Break  
}  
  
# General settings  
$VpnName = Read-host -Prompt "Whats the name of the VPN Connection?" 
$gateway = Read-Host -Prompt "Whats the gateway of the VPN Connection" 
write-host "$vpnname " -f yellow -NoNewline ; write-host "is the name of the connection and gateway" -NoNewline ; write-host " $gateway." -f Yellow  
$psk = Read-Host -Prompt "Enter preshared key for the VPN"  
$regp = 'HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent' # If VPN server is behind NAT, otherwise comment out this line.  
  
# Add L2TP VPN
try {  
  Add-VpnConnection -Name $VpnName -ServerAddress $gateway -TunnelType L2tp -AuthenticationMethod MSChapv2 -EncryptionLevel Optional -L2tpPsk $psk -AllUserConnection -UseWinLogonCredential $false -SplitTunneling -Force
  Write-Host "Connection has been added." -f Green    
}
Catch {
  $error.clear()
  $ErrorMessage = $_.exception.Message
  Write-Error "ERROR: $errormessage"
}
 
# Add registry value, if VPN server is behind NAT. Otherwise comment out this line.
try {  
  New-ItemProperty -Path $regp -Name AssumeUDPEncapsulationContextOnSendRule -Value 2 -PropertyType 'DWORD' -Force  
} 
Catch {
  $error.clear()
  $ErrorMessage = $_.exception.Message
  Write-Error "ERROR: $errormessage"
}
  
$confirm = Read-Host -Prompt '... L2Tp over IPsec is added. System needs to be restarted before the VPN connection can work. Reboot system? Y/N ...'  
 
If (($confirm -eq "Y")) { 
  Restart-Computer 
}
else { 
  $cp = Read-Host -Prompt "Ok. Closing Powershell? Y/N" 
     
  if (($cp -eq "Y")) { 
    ncpa.cpl 
    Get-Process powershell | Stop-Process 
  }
  else { 
    ncpa.cpl 
  } 
} 