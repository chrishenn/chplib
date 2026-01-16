function sec_admin {
    $id = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $id.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
}

function sec_uac {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
    rprop $key 'ConsentPromptBehaviorAdmin' 'DWORD' 0
    rprop $key 'EnableLUA' 'DWORD' 0
}

function _sec_pwsh ($scopes = @('localmachine', 'currentuser'), $pol = 'unrestricted') {
    foreach ($scope in $scopes) {
        try {
            Set-ExecutionPolicy -force -scope $scope -ExecutionPolicy $pol
        } catch {
            write-host -f y "sec_pwsh: error setting {scope: $scope, policy: $pol}"
        }
    }
}

function sec_pwsh {
    # pass args as: ` pwsh -c ${function:_sec_pwsh} -args "'localmachine' 'unrestricted'" `
    _sec_pwsh

    if (inst_app pwsh) {
        pwsh -c ${function:_sec_pwsh}
    }
    if (inst_app powershell) {
        powershell -c ${function:_sec_pwsh}
    }
}

function sec_defender {
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
    rprop $key 'DisableAntiVirus' 'DWORD' 1
    rprop $key 'DisableBehaviorMonitoring' 'DWORD' 1
    rprop $key 'DisableOnAccessDetection' 'DWord' 1
    rprop $key 'DisableScanOnRealtimeEnable' 'DWord' 1
    rprop $key 'DisableAntiSpyware' 'DWord' 1
    rprop $key 'DisableSpecialRunningModes' 'DWORD' 1
    rprop $key 'DisableTamperProtection' 'DWORD' 1
    rprop $key 'DisableAntiSpywareDefinitionUpdate' 'DWORD' 1
    rprop $key 'AllowCloudProtection' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection'
    rprop $key 'DisableRealtimeMonitoring' 'DWORD' 1
    rprop $key 'DisableBehaviorMonitoring' 'DWord' 1
    rprop $key 'DisableOnAccessProtection' 'DWord' 1
    rprop $key 'DisableScanOnRealtimeEnable' 'DWord' 1
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet'
    rprop $key 'DisableBlockAtFirstSeen' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting'
    rprop $key 'DisableEnhancedNotifications' 'DWORD' 1
    rprop $key 'DisableGenericReports' 'DWORD' 1
    rprop $key 'DisableGenericRemediation' 'DWORD' 1
}

function sec_pw {
    # password expiry: disable
    $key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordPolicy"
    rprop $key "DisablePasswordExpiration" "DWORD" 1

    # require sign-in
    $key = 'HKCU:\Control Panel\Desktop'
    rprop $key 'DelayLockInterval' 'DWORD' 0xffffffff
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    rprop $key 'DisableLockWorkstation' 'DWORD' 1

    # dev mode, sudo
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    rprop $key 'AllowDevelopmentWithoutDevLicense' 'DWORD' 1
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo'
    rprop $key 'Enabled' 'DWORD' 1
}

function sec_ucpd {
    # requires restart to take effect
    [void](Disable-ScheduledTask '\Microsoft\Windows\AppxDeploymentClient\UCPD velocity')
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\UCPD'
    rprop $key 'Start' 'DWORD' 4
}

function sec_ie {
    $key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
    rprop $key 'IsInstalled' 'DWORD' 0
    $key = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
    rprop $key 'IsInstalled' 'DWORD' 0
}

function sec_spy {
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    rprop $key 'EnableSmartScreen' 'DWORD' 0
    rprop $key 'EnableActivityFeed' 'DWORD' 0
    rprop $key 'PublishUserActivities' 'DWORD' 0
    rprop $key 'UploadUserActivities' 'DWORD' 0
}
