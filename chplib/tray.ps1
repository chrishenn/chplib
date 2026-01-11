function tray_hide (
    [Parameter(Mandatory = $false, HelpMessage = 'Program names to set hide value for')][string[]] $names,
    [Parameter(Mandatory = $false, HelpMessage = '{1: show, 0: hide (collapse)}')]
    [ValidateScript({
        if ($_ -lt 0 -or $_ -gt 1) {
            throw 'Invalid setting'
        } return $true
    })]
    [Int16] $val = 0
) {
    $key = 'HKCU:\Control Panel\NotifyIconSettings'
    foreach ($name in $names) {
        $found = $false
        foreach ($guid in (gci $key -Name)) {
            $child = "$key\$guid"
            $exec = (Get-ItemProperty $child ExecutablePath -ea 0).ExecutablePath

            if ($exec -match $name) {
                write-host -f green "Setting tray: {key: $child, val: $val, program: $name}"
                rprop $child 'IsPromoted' 'DWORD' $val
                $found = $true
                break
            }
        }
        if (-not $found) {
            write-host "tray icon setting key for ($name) was not found"
        }
    }
}
