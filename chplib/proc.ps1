function proc (
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string] $bname,
    [string[]] $arg = ''
) {
    return (start $bname -nonewwindow -wait -passthru -a $arg -RedirectStandardOutput "NUL").exitcode
}
