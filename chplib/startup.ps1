enum Sources {
    registry
    folder
}

class app {
    [ValidateNotNullOrEmpty()][Sources] $source
    [ValidateNotNullOrEmpty()][string] $path
    [ValidateNotNullOrEmpty()][string] $name
}

function _namefilter (
    [string[]] $names = @(),
    [string[]] $tgts = @()
) {
    # if names specd, match any tgts that match any names, returning unique matches
    if (-not ($names)) {
        return $tgts
    }

    $found = @()
    foreach ($name in $names) {
        $found += $tgts -match $name
    }
    return ($found | select-object -unique)
}

function startup_reg (
    [string[]] $names = @()
) {
    # if names is specd, only return apps with names in names
    $startup_paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    $apps = @()
    foreach ($path in $startup_paths) {
        if (-not (Test-Path $path)) {
            continue
        }
        $pnames = get-item $path | select-object -expandproperty Property
        if (-not ($pnames)) {
            continue
        }
        $pnames = _namefilter $names $pnames
        foreach ($pname in $pnames) {
            $apps += [app]@{
                source = [Sources]::registry
                path = $path
                name = $pname
            }
        }
    }
    return $apps
}

function startup_dir (
    [string[]] $names = @()
) {
    # if names is specd, only return apps with names in names
    $startup_dirs = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ALLUSERSPROFILE\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    $apps = @()
    foreach ($dir in $startup_dirs) {
        if (-not (Test-Path $dir)) {
            continue
        }
        $files = gci $dir -file
        if (-not ($files)) {
            continue
        }
        $fnames = _namefilter $names $files.name
        foreach ($fname in $fnames) {
            $apps += [app]@{
                source = [Sources]::folder
                path = $dir
                name = $fname
            }
        }
    }
    return $apps
}

function startup_rm (
    [Parameter(ValueFromPipeline, Mandatory = $true)][ValidateNotNullOrEmpty()][string[]] $names
) {
    $apps = @()
    $apps += startup_reg $names
    $apps += startup_dir $names

    if (-not $apps) {
        write-host -f y "No matching startup applications found for names: $names"
    }
    foreach ($app in $apps) {
        $src = $app.source
        $path = $app.path
        $name = $app.name
        try {
            switch ($src) {
                ([Sources]::registry) {
                    Remove-ItemProperty $path -Name $name -ErrorAction Stop
                }
                ([Sources]::folder) {
                    ri (Join-Path -Path $path -ChildPath $name) -ErrorAction Stop
                }
            }
            write-host -f green "Startup app removed from:"
            write-host -f green "$($app | format-list | out-string)"
        } catch {
            write-host -f y "Failed to remove startup app:"
            write-host -f y "$($app | format-list | out-string)"
        }
    }
}

function startup_ls (
    [string[]] $names = @(),
    [switch] $verbose = $false
) {
    $apps = @()
    $apps += startup_reg $names
    $apps += startup_dir $names

    if ($verbose) {
        $apps | Format-list
    } else {
        $apps.name
    }
}
