. $psscriptroot\types.ps1

# Note: the pnpdevice class is only assigned when a driver is assigned to the device.
#   In the case of these igpu's, I'm assuming that the MS basic display driver will be correctly assigned by default.
# Realistically, you need to tabulate all the device instanceids that you care about and match them
#    to robustly detect your devices of interest here (possibly vendorid and any HardwareID, CompatibleID for a device)
# Doing dumb string regex quickly also means compiling a native binary ... later.
# Haxx ahead for now

function hw_cpu {
    if (get-pnpdevice -class processor -instanceid 'ACPI\AUTHENTICAMD*' -ea 0) {
        return [Cpu]::amd
    }
    if (get-pnpdevice -class processor -instanceid 'ACPI\GENUINEINTEL*' -ea 0) {
        return [Cpu]::intel
    }
    return [Cpu]::unknown
}

function hw_nvgpu {
    return get-pnpdevice -present -class display | ? {$_.manufacturer -eq "nvidia"}
    # return gcim Win32_VideoController | ? {$_.VideoProcessor -match "nvidia"}
}

function hw_nvwait (
    [int] $timeout = 120,
    [int] $pause = 10
) {
    $waited = 0
    while (-not ($gpu = hw_nvgpu)) {
        write-host "nv_wait: waiting for nv_gpu with timeout: $timeout seconds"
        start-sleep -s $pause

        $waited += $pause
        if ($waited -ge $timeout) {
            write-host "nv_wait: exiting after waiting for more than timeout: $timeout seconds"
            return $null
        }
    }
    return $gpu
}

function hw_amdapu {
    # assumes that the MS basic display driver will be correctly assigned by default
    $venstr = "ven_1002"
    return Get-pnpdevice -present -class display | ? {$_.instanceid -match $venstr}
}

function hw_intelapu {
    # assumes that the MS basic display driver will be correctly assigned by default
    $venstr = "ven_8086"
    return Get-pnpdevice -present -class display | ? {$_.instanceid -match $venstr}
}

function hw_intelwifi {
    # according to https://www.devicekb.com/hardware/pci-vendors/ven_8086-dev_272b
    # PCI\VEN_8086&DEV_272B is recognized as Intel Wi-Fi 7 AX1775*/AX1790*/BE20*/BE401/BE1750* 2x2
    # and
    # Hardware ID PCI\VEN_8086&DEV_51F1 is recognized as Raptor Lake PCH CNVi WiFi
    # in practice, this matched my killer AX211, and the intel driver chris/intelwifi worked for it
    $devstr = '(PCI\\VEN_8086&DEV_272B|PCI\\VEN_8086&DEV_51F1)'
    return Get-pnpdevice | ? {$_.instanceid -match $devstr}
}
