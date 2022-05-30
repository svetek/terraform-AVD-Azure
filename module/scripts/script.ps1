[CmdletBinding()]

param
(
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$RegistrationToken,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$FslogixEnable,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$FslogixShare,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$DuoEnable,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$DuoIKEY,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$DuoSKEY,
    [Parameter(ValuefromPipeline=$true,Mandatory=$true)] [string]$DuoHostAPI
)


$registryPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
$FsLogixSharePatch  = $FslogixShare -replace "https://","\\" -replace "/","\"


$scriptStartTime = get-date

#Create temp folder
New-Item -Path 'C:\temp\apps' -ItemType Directory -Force | Out-Null

#Download all source file async and wait for completion
$scriptActionStartTime = get-date
Write-host ('*** STEP 0 : Download all sources [ '+(get-date) + ' ]')
$files = @(
    @{url = "https://dl.duosecurity.com/duo-win-login-latest.exe"; path = "c:\temp\apps\duo-win-login-latest.exe"}
    @{url = "https://download.microsoft.com/download/4/8/2/4828e1c7-176a-45bf-bc6b-cce0f54ce04c/FSLogix_Apps_2.9.7654.46150.zip"; path = "c:\temp\apps\fslogix.zip"}
    @{url=  "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"; path = "c:\temp\apps\Microsoft.RDInfra.RDAgent.Installer-x64-1.0.3050.2500.msi"}
    @{url=  "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"; path = "c:\temp\apps\Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi"}
)

foreach ($f in $files)
{
    Write-Output "DOWNLOAD $f"
    $wc = New-Object System.Net.WebClient
    Write-Output $wc.DownloadFileTaskAsync($f.url, $f.path)
}

$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "Total source Download time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"

 #Install AVD RDAgent


 if (!$RegistrationToken) {
        throw "No registration token specified"
    }


Write-Output "Installing RD Infra Agent on VM $AgentInstaller"
$processResult = Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i C:\temp\apps\Microsoft.RDInfra.RDAgent.Installer-x64-1.0.3050.2500.msi /quiet /qn /norestart /passive REGISTRATIONTOKEN=$RegistrationToken" -Wait
$sts = $processResult.ExitCode
Write-Output $s

Write-Output "Installing RDAgent BootLoader on VM $AgentBootServiceInstaller"
$processResult = Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i C:\temp\apps\Microsoft.RDInfra.RDAgentBootLoader.Installer-x64.msi /quiet /qn /norestart /passive" -Wait
$sts = $processResult.ExitCode
Write-Output $s



#Install FSLogix
$scriptActionStartTime = get-date
Write-host ('*** STEP 1 : Install FSLogix Apps [ '+(get-date) + ' ]')
Expand-Archive -Path 'C:\temp\apps\fslogix.zip' -DestinationPath 'C:\temp\apps\fslogix\'  -Force
Start-Sleep -Seconds 10
Start-Process -FilePath 'C:\temp\apps\fslogix\x64\Release\FSLogixAppsSetup.exe' -ArgumentList '/install /quiet /norestart' -Wait
$scriptActionDuration = (get-date) - $scriptActionStartTime
Write-Host "*** FSLogix Install time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"


#Configure FSLogix
# https://admx.help/?Category=FSLogixApps&Policy=FSLogix.Policies::a8b1f74b18543adf46ea806a5ddfea02
New-ItemProperty -Path $registryPath -Name "Enabled" -Value $FslogixEnable -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "DeleteLocalProfileWhenVHDShouldApply" -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "PreventLoginWithFailure" -Value 0 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "PreventLoginWithTempProfile" -Value 0 -PropertyType DWORD -Force | Out-Null

# MULTIPLY SESSIONS
New-ItemProperty -Path $registryPath -Name "ConcurrentUserSessions" -Value 1 -PropertyType DWORD -Force | Out-Null
# New-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\FSLogix\ODFC" -Name "ConcurrentUserSessions" -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "VHDLocations" -Value $FsLogixSharePatch -PropertyType MultiString -Force | Out-Null

 ######################
# Install DUO Login https://help.duo.com/s/article/1090?language=en_US
# $DuoIKEY = "DIXXXXXXXXXXXXXXXXXXXX"
# $DuoSKEY = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# $DuoHostAPI = "api-xxxxxxxx.duosecurity.com"
if ($DuoEnable) {
    $DuoArguments = @('/S', '/V"', '/qn', "IKEY=$DuoIKEY", "SKEY=$DuoSKEY", "HOST=$DuoHostAPI", 'AUTOPUSH="#1"', 'FAILOPEN="#1"', 'SMARTCARD="#0"', 'RDPONLY="#0"', 'UAC_PROTECTMODE=#2')

    echo $DuoArguments

    $scriptActionStartTime = get-date
    Write-host ('*** STEP 1 : Install DUO Apps [ '+(get-date) + ' ]')
    Start-Process -FilePath 'c:\temp\apps\duo-win-login-latest.exe' -ArgumentList $DuoArguments -Wait
    $scriptActionDuration = (get-date) - $scriptActionStartTime
    Write-Host "*** DUO Install time: "$scriptActionDuration.Minutes "Minute(s), " $scriptActionDuration.seconds "Seconds and " $scriptActionDuration.Milliseconds "Milleseconds"
}
# Set params for RDP sessions timers
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fResetBroken /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime /t REG_DWORD /d 43200000 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxConnectionTime /t REG_DWORD /d 43200000 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxDisconnectionTime /t REG_DWORD /d 600000 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v RemoteAppLogoffTimeLimit /t REG_DWORD /d 0 /f

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v NoWarningNoElevationOnInstall /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v UpdatePromptSettings /t REG_DWORD /d 1 /f


# Restart computer
# Restart-Computer -Force