function keyadd (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key
) {
    if (!(Test-Path "$key")) {
        [void](ni "$key" -Force)
    }
}

function propexist (
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

function setprop (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $key,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $name,
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()] $type,
    [parameter(Mandatory = $true)] $Value
) {
    keyadd "$key"
    if (-not (propexist "$key" "$name")) {
        [void](new-itemProperty "$key" -Name "$name" -PropertyType $type -Value $Value -Force)
    } else {
        [void](Set-ItemProperty "$key" -Name "$name" -Type $type -Value $Value -Force)
    }
}
