function pwr_unhide {
    # https://gist.github.com/Velocet/7ded4cd2f7e8c5fa475b8043b76561b5
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings'
    $cfg = (gci $key -Recurse).Name -notmatch '\bDefaultPowerSchemeValues|(\\[0-9]|\b255)$'
    foreach ($item in $cfg) {
        rprop $item.Replace('HKEY_LOCAL_MACHINE', 'HKLM:') 'Attributes' 'DWORD' 2
    }
}

function pwr_throttling {
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling'
    rprop $key 'PowerThrottlingOff' 'DWORD' 1
}

function pwr_hybridsleep {
    $key = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\94ac6d29-73ce-41a6-809f-6363ba21b47e'
    rprop $key 'ACSettingIndex' 'DWORD' 0
    rprop $key 'DCSettingIndex' 'DWORD' 0
}

function pwr_standby {
    # modern standby
    $key = 'HKLM:\System\CurrentControlSet\Control\Power'
    rprop $key 'PlatformAoAcOverride' 'DWORD' 0
    # connected standby
    $key = 'HKLM:\System\CurrentControlSet\Control\Power'
    rprop $key 'CSEnabled' 'DWORD' 0
}

function pwr_hybernate {
    powercfg /h off
}

function pwr_scheme (
    [string] $sname,
    [string] $sguid,
    [string] $sdefault
) {
    # enable power scheme with name sname and builtin guid sguid. return sdefault on error
    # todo: the builtin scheme's guid sguid must match the name of the scheme you want to enable, for now
    if (-not (get-module -listavailable powercfg)) {
        install-module powercfg -force -skippublishercheck
    }
    import-module powercfg

    if (-not ((Get-PowercfgScheme).name -contains $sname)) {
        powercfg /DuplicateScheme $sguid
    }
    if ($sch = Get-PowercfgScheme | ? {$_.name -eq $sname}) {
        return $sch.guid.guid
    }
    return $sdefault
}

function pwr_ultimate (
    [string] $sname = 'Ultimate Performance',
    [string] $sguid = 'e9a42b02-d5df-448d-aa00-03f14749eb61',
    [string] $sdefault = 'SCHEME_CURRENT'
) {
    return (pwr_scheme $sname $sguid $sdefault)
}

function pwr_dpst (
    [switch] $enable = $false,
    [switch] $status = $false
) {
    # usage:
    #   dpst -enable # enable dpst [default: false ("disable")]
    #   dpst -status # print dpst status and return

    $ftcname = "FeatureTestControl"
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
    $keys = gci -ea 0 "$key" | ? {$_.Name -match '\\\d{4}$'}

    $ftc_path = ""
    foreach ($key in $keys) {
        if ($key.GetValue($ftcname, $null) -ne $null) {
            $ftc_path = $key.name
            break
        }
    }
    if (-not $ftc_path) {
        Write-Error "Cannot locate ftc in registry"
        return
    }

    $ftc = (Get-Item "Registry::${ftc_path}").GetValue($ftcname)
    $bitmask = 1 -shl 4
    $enabled = -not [bool]($ftc -band $bitmask)
    $enabled_str = if ($enabled) {
        "enabled"
    } else {
        "disabled"
    }

    if ($status) {
        Write-host -f c "DPST is: $enabled_str"
        return
    }

    $ftc_new = 0
    if ($enable -and -not $enabled) {
        Write-host -f c "DPST is disabled; enabling"
        $ftc_new = $ftc -band (-bnot $bitmask)
    } elseif (-not $enable -and $enabled) {
        Write-host -f c "DPST is enabled; disabling"
        $ftc_new = $ftc -bor $bitmask
    } else {
        Write-host -f green "DPST unchanged | requested {enabled: $enabled} | currently {enabled: $enabled}"
        return
    }
    rprop "Registry::$ftc_path" "$ftcname" "DWORD" $ftc_new
    Write-host -f green "Set DPST. Reboot is required for changes to take effect"
}
