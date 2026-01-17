function inst_gcm (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    return [bool](gcm $name -ea 0)
}

function inst_scoop (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    if (-not (inst_gcm scoop)) {
        return $false
    }
    return ((scoop export | ConvertFrom-Json).apps | ? {$_.name -eq "$name"} | measure).count -gt 0
}

function inst_reg (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    $apps = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $apps += Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    return ($apps | ? {$_.displayname -match "$name"} | measure).count -gt 0
}

function inst_app (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $name
) {
    # note: inst_scoop matches name exactly (case-insensitive)
    # sys_app/inst_reg matches on "real app name -match (contains) $name"
    # gcm passes $name directly to powershell `get-command $name`
    return (inst_reg $name) -or (inst_scoop $name) -or (inst_gcm $name)
}
