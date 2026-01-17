function scoop_bucket (
    [string[]] $buckets = @()
) {
    # bucket add is idempotent; no need for manual check
    foreach ($name in $buckets) {
        try {
            $tmp = $name.split(' ')
            scoop bucket add @tmp
        } catch {
            write-host -f y "scoop_bucket: error while adding bucket: $name"
        }
    }
    scoop update
}

function scoop_app_be (
    [string[]] $apps = @()
) {
    # this is much slower than splatting install
    foreach ($app in $apps) {
        try {
            scoop install $app
        } catch {
            write-host -f y "scoop_app_be: error while installing: $app"
        }
    }
}

function scoop_app (
    [string[]] $apps = @(),
    [switch] $best_effort = $false
) {
    # scoop bug: may throw an incorrect error when an app in apps has a dependency, and they are both already installed
    try {
        scoop install @apps
    } catch {
        write-host -f y "scoop_app: error while installing packages: $apps"
        if ($best_effort) {
            scoop_app_be $apps
        }
    }
}

function scoop_shim (
    [string[]] $shims = @()
) {
    # adding a shim is NOT idempotent; manual check is needed
    foreach ($pair in $shims) {
        try {
            # adding shims using `scoop add` is NOT idempotent, so this check is necessary
            $split = $pair.split(' ')
            if (-not ($split[0] -and $split[1])) {
                write-host -f y "scoop_shim: malformed shim: $pair"
                return
            }
            if (scoop shim info $split[0]) {
                write-host -f green "scoop_shim: already exists for: $pair"
            } else {
                scoop shim add $split[0] $(scoop which $split[1])
            }
        } catch {
            write-host -f y "scoop_shim: error while adding shim: $pair"
        }
    }
}

function scoop_base (
    [string[]] $basepkgs = @()
) {
    if (-not (inst_gcm scoop)) {
        write-host -f c 'scoop_base: installing scoop'
        iex "& {$(irm get.scoop.sh -useb)} -RunAsAdmin"
    }
    if ($basepkgs) {
        scoop_app $basepkgs -best_effort
    }
    scoop config aria2-warning-enabled false
}
