. $psscriptroot\types.ps1

function svc_startup (
    [Parameter(Mandatory = $true)][string[]] $names,
    [Parameter(Mandatory = $true)][Start] $startup
) {
    # usage: {svc_startup "csc" "disabled"} or {svc_startup "csc" 4} or {svc_startup "csc" ([Start]::disabled)}
    foreach ($name in $names) {
        $key = "HKLM:\SYSTEM\CurrentControlSet\Services\$name"
        rprop $key 'Start' 'DWORD' $([int]$startup)
    }
}

function svc_disable (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    foreach ($name in $names) {
        stop-service $name -force -ea 0
        svc_startup $name ([Start]::disabled)
    }
}

function svc_rm (
    [Parameter(Mandatory = $true)][string[]] $names
) {
    foreach ($name in $names) {
        svc_disable $name
        remove-service $name -ea 0
    }
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
    return (gci $key | where-object {$_.PSChildName -match $name})
}
