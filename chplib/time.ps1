. $psscriptroot\types.ps1

function time_sync {
    # requires time_sync_enable; sets the setting 'set time automatically' and gates the w32tm service
    time_sync_enable
    start-service w32time
    w32tm /resync /force
}

function time_sync_enable {
    # set to "NoSync" to disable
    $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters'
    rprop $key 'Type' 'String' 'NTP'
    svc_startup w32time ([Start]::automatic)
}

function time_tz_auto {
    svc_startup tzautoupdate ([Start]::automatic)
}
