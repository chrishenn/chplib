function _ustr (
    $name
) {
    $key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    $chld = gci $key | get-itemproperty | Where-Object {$_.DisplayName -match "$name"}
    if ($chld) {
        return $chld.uninstallstring
    }
    return $null
}

function apprm_msi (
    $name
) {
    # uninstall with msiexec via registry uninstall string
    if (!($ustr = (_ustr $name))) {
        write-host -f r "failed to find uninstall string for: $name"
        return 1
    }
    if (!($ustr -match 'msiexec')) {
        write-host -f r "uninstall string is not msiexec for: $name"
        return 1
    }
    $ustr = $ustr.replace('msiexec.exe', '', 'OrdinalIgnoreCase')
    $ustr = $ustr.replace('msiexec', '', 'OrdinalIgnoreCase')
    $ustr += ' /quiet'
    echo "uninstalling with msiexec and: $ustr"
    start-process msiexec -wait -NoNewWindow -a $ustr
}
