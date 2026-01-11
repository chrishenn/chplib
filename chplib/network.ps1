function net_smbsettings {
    Set-SmbServerConfiguration -EnableMultiChannel $true -force
    Set-SmbClientConfiguration -EnableMultiChannel $true -force

    # you would expect a perf hit from this, but not sure
    # $key = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
    # rprop $key 'RequireSecuritySignature' 'DWORD' 0
    # Set-SmbClientConfiguration -RequestCompression $true -Confirm:$false
}

function net_firewall {
    # set firewall permissive (but don't disable; needed for ame blocking)
    Set-NetFirewallProfile -Profile Domain, Public, Private -DefaultInboundAction Allow
    Set-NetFirewallProfile -Profile Domain, Public, Private -DefaultOutboundAction Allow
}

function net_mntshare (
    [string[]][ValidateNotNullOrEmpty()] $pairs
) {
    foreach ($pair in $pairs) {
        $split = $pair.split(' ')
        if (-not ($split[0] -and $split[1])) {
            write-host -f r "mntshare: 'pair' must include mount letter and network share path eg: 'H: \\192.168.1.142\h'"
        }
        New-SmbMapping -ea 0 -LocalPath $split[0] -RemotePath $split[1] -persistent $true
    }
}

function net_up {
    $x = gcim Win32_NetworkAdapterConfiguration -filter DHCPEnabled=TRUE | where {$_.DefaultIPGateway -ne $null}
    return ($x | measure).count -gt 0
}

function net_wait (
    [int] $timeout = 300,
    [int] $pause = 10
) {
    $waited = 0
    while (-not (net_up)) {
        write-host "NETWORK: waiting for network"
        start-sleep -s $pause

        waited += $pause
        if (waited -ge $timeout) {
            write-host "NETWORK: timed out after waiting for {$timeout} seconds"
            return $false
        }
    }
    return $true
}

function net_dlretry (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $src,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $dst
) {
    write-host "DL: start transfer"

    $done = $false
    while (-not $done) {
        try {
            iwr $src -OutFile $dst -useb
            $done = $true
        } catch {
            write-host "NETWORK: caught error while downloading; waiting for network; retrying in 5s"
            file_rmf $dst
            net_wait
        }
    }
}
