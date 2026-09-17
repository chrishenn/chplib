. $psscriptroot\types.ps1

function svc_startup (
    [Parameter(Mandatory = $true)][string[]] $names,
    [Parameter(Mandatory = $true)][Start] $startup
) {
    # usage: {svc_startup "csc" "disabled"} or {svc_startup "csc" 4} or {svc_startup "csc" ([Start]::disabled)}
    foreach ($name in $names) {
        if (-not ($svc = get-service $name -ea 0)) {
            write-host -f y "WARN svc_startup: no service found with name $name"
            continue
        }
        $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.name)"
        rprop $key 'Start' 'DWORD' ([int]$startup)
    }
}

function svc_disable (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    foreach ($name in $names) {
        if (-not ($svc = get-service $name -ea 0)) {
            write-host -f y "WARN svc_disable: no service found with name $name"
            continue
        }
        stop-service -ea 0 -force $svc

        $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.name)"
        rprop $key 'Start' 'DWORD' ([int][Start]::disabled)
    }
}

function svc_rm (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    # use registry to disable svc
    foreach ($name in $names) {
        if (-not ($svc = get-service $name -ea 0)) {
            write-host -f y "WARN svc_rm: no service found with name $name"
            continue
        }
        stop-service -ea 0 -force $svc

        $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.name)"
        rprop $key 'Start' 'DWORD' ([int][Start]::disabled)

        if ($PSVersionTable.PSVersion.Major -gt 5) {
            remove-service -ea 0 -inputobject $svc
        } else {
            [void](sc.exe delete $svc)
        }
    }
}

function svc_pwsh_rm (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    # use pwsh set-service to disable svc
    foreach ($name in $names) {
        if (-not ($svc = get-service $name -ea 0)) {
            write-host -f y "WARN svc_pwsh_rm: no service found with name $name"
            continue
        }
        stop-service -ea 0 -force $svc
        if ($PSVersionTable.PSVersion.Major -gt 5) {
            set-service -ea 0 -force $svc -startuptype ([Start]::disabled)
            remove-service -ea 0 -inputobject $svc
        } else {
            set-service -ea 0 -inputobject $svc -startuptype ([Start]::disabled)
            [void](sc.exe delete $svc)
        }
    }
}

function svc_start_wait (
    [Parameter(Mandatory = $true)][string] $name,
    [int] $timeout = 30,
    [int] $pause = 3
) {
    if ([string](get-service $name).status -eq [SvcState]::running) {
        return $true
    }
    start-service $name
    [int] $loops = max ($timeout / $pause), 1
    while ([string](get-service $name).status -ne [SvcState]::running) {
        $loops -= 1
        if ($loops -le 0) {
            break
        }
        start-sleep 3
        write-host "waiting for ($name) to start"
    }
    if ([string](get-service $name).status -ne [SvcState]::running) {
        write-host -f r "error: ($name) did not start after waiting for ($timeout) seconds"
        return $false
    }
    return $true
}

function svc_start (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    foreach ($name in $names) {
        start-service -name $name -ea 0
    }
}

function svc_stop (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    foreach ($name in $names) {
        stop-service -name $name -force -ea 0
    }
}

function svc_stems (
    [Parameter(Mandatory = $true)][string[]] $stems
) {
    # pass array of strings, where service name starts with stem and ends in random string of chars
    # passed array is modified in-place with full service names
    for ($i = 0; $i -lt $stems.count; $i++) {
        $stem = $stems[$i]
        $svc_obj = get-service -Name "$stem*"
        $stems[$i] = $svc_obj.Name
    }
}

function svc_regfind (
    [string] $name
) {
    # match by service name, not by displayname. return found reg props
    $key = "HKLM:\SYSTEM\CurrentControlSet\Services"
    return (gci $key | ? {$_.PSChildName -match $name})
}
