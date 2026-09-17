. $psscriptroot\types.ps1

function time_sync_enable {
    # set to "NoSync" to disable
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters'
    rprop $key 'Type' 'String' 'NTP'

    w32tm /register
    svc_startup w32time ([Start]::automatic)
    svc_start_wait w32time
}

function time_cf {
    $ntpsrv = "time.cloudflare.com,0x8"
    if ($ret = proc w32tm "/config /manualpeerlist:$ntpsrv /syncfromflags:manual /update") {
        write-host -f r "error setting ntpserver; errno: $ret"
        return $false
    }
    return $true
}

function time_tz_auto {
    svc_startup tzautoupdate ([Start]::automatic)
    svc_start_wait tzautoupdate
}

function time_sync {
    if ($ret = proc w32tm '/resync /force') {
        write-host -f r "error syncing with ntpserver; errno: $ret"
        return $false
    }
    return $true
}
