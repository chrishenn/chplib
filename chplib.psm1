. $psscriptroot\src\app_install.ps1
. $psscriptroot\src\app_startup.ps1
. $psscriptroot\src\app_x.ps1
. $psscriptroot\src\autologin.ps1
. $psscriptroot\src\chplib.psm1
. $psscriptroot\src\dpst.ps1
. $psscriptroot\src\file.ps1
. $psscriptroot\src\hardware.ps1
. $psscriptroot\src\network.ps1
. $psscriptroot\src\path.ps1
. $psscriptroot\src\pwr.ps1
. $psscriptroot\src\registry.ps1
. $psscriptroot\src\scoop.ps1
. $psscriptroot\src\svc.ps1
. $psscriptroot\src\tray.ps1

$export = @{
    Function = @(
        'gcm_app',
        'scoop_app',
        'reg_app',
        'installed',
        'instexe',
        'interactive',
        'find_ustr',
        'ustr',
        'startups_reg',
        'startups_folder',
        'startup_rm',
        'startups_rm',
        'appx_find',
        'appx_rm',
        'appxsys_find',
        'appxsys_rm',
        'autologin',
        'autologin_it',
        'dpst',
        'takeowner',
        'rm_force',
        'cpu',
        'nvidia_gpu',
        'nv_wait',
        'amd_apu',
        'intel_apu',
        'intel_wifi',
        'network_up',
        'network_wait',
        'dl_retry',
        'mntshare',
        'mntshares',
        'smb_settings',
        'path_reload',
        'path_ls',
        'path_in',
        'path_add',
        'path_rm',
        'modern_standby_disable',
        'connected_standby_disable',
        'pwr_unhide',
        'keyadd',
        'propexist',
        'setprop',
        'scoop_base',
        'scoop_bucket',
        'scoop_buckets',
        'scoop_apps',
        'scoop_shim',
        'scoop_shims',
        'scoop_boot',
        'svc_regfind',
        'svc_startup',
        'svcs_startup',
        'svc_disable',
        'svcs_disable',
        'svc_rm',
        'svcs_rm',
        'svcs_start',
        'svcs_stop',
        'svcs_stems',
        'tray_hide',
        'trays_hide'
    )
}

export-modulemember @export