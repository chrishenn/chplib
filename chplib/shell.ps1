function shell_interactive {
    $noni = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonI*' }
    return ([Environment]::UserInteractive -and -not $noni)
}