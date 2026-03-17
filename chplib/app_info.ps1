function appinfo_reg ([string] $name = "", [string] $user = $env:username) {
    $acc = New-Object System.Security.Principal.NTAccount($user)
    $sid = $acc.translate([System.Security.Principal.SecurityIdentifier]).value
    $userkey = "Registry::HKEY_USERS\$sid"

    $apps = gp "$userkey\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $apps += gp "$userkey\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $apps += gp "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $apps += gp "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"

    if ($name) {
        return ($apps | ? {$_.displayname -match $name})
    }
    return $apps
}