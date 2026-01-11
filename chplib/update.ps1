function update_all {
    write-host -f c 'update'
    if (-not (Get-Module -ListAvailable PSWindowsUpdate)) {
        Install-Module PSWindowsUpdate -force -SkipPublisherCheck
    }
    Import-Module PSWindowsUpdate
    Install-WindowsUpdate -NotTitle OneDrive -AcceptAll -IgnoreReboot
}

function update_activate (
    [string] $mthd = '/HWID'
) {
    write-host -f c 'activate'
    try {
        iex "& {$(irm https://get.activated.win)} $mthd"
    } catch {
        write-host -f r "SETUP: activate failed for method: $mthd"
    }
}