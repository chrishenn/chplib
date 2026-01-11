function rkeyadd (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key
) {
    if (!(Test-Path "$key")) {
        [void](ni "$key" -Force)
    }
}

function rpropexist (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $val
) {
    # when key has no properties, this is null
    $prop = Get-ItemProperty $key -ea 0
    if ($null -eq $prop) {
        return $false
    }
    if ($null -eq ($prop | Select-Object -ExpandProperty $val -ea 0)) {
        return $false
    }
    return $true
}

function rprop (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $name,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $type,
    [parameter(Mandatory = $true)] $val
) {
    rkeyadd "$key"
    if (-not (rpropexist "$key" "$name")) {
        [void](new-itemProperty "$key" -Name "$name" -PropertyType $type -Value $val -Force)
    } else {
        [void](Set-ItemProperty "$key" -Name "$name" -Type $type -Value $val -Force)
    }
}
