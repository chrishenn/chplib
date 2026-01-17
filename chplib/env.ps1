function env_interactive {
    $noni = [Environment]::GetCommandLineArgs() | ?{$_ -like '-NonI*'}
    return ([Environment]::UserInteractive -and -not $noni)
}