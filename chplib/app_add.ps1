function appadd_exe (
    [string] $exe,
    [string] $arg = '/i /quiet /passive /S /qn /silent',
    [int] $timeoutms = 60000
) {
    # silent install from exe with 1-minute timeout
    write-host -f c "installing with 1-minute timeout: $exe"
    $proc = start-process "$exe" -a "$arg" -NoNewWindow -passthru
    if (-not ($proc.waitforexit($timeoutms))) {
        write-host -f r "ERROR: timeout while installing: $exe"
        return 1
    }
}
