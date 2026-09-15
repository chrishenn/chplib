. $psscriptroot\types.ps1

[System.Collections.Generic.HashSet[string]] $svc_user_known = @(
    'AarSvc'
    'BluetoothUserService'
    'CaptureService'
    'cbdhsvc'
    'CDPUserSvc'
    'CloudBackupRestoreSvc'
    'ConsentUxUserSvc'
    'PimIndexMaintenanceSvc'
    'CredentialEnrollmentManagerUserSvc'
    'DeviceAssociationBrokerSvc'
    'DevicePickerUserSvc'
    'DevicesFlowUserSvc'
    'BcastDVRUserService'
    'MessagingService'
    'NPSMSvc'
    'OneSyncSvc'
    'P9RdrService'
    'PenService'
    'PrintWorkflowUserSvc'
    'UdkUserSvc'
    'UserDataSvc'
    'UnistoreSvc'
    'WpnUserService'
)

$svc_user = @(
    'CaptureService'
    'cbdhsvc'
    'CDPUserSvc'
    'CloudBackupRestoreSvc'
    'ConsentUxUserSvc'
    'PimIndexMaintenanceSvc'
    'BcastDVRUserService'
    'NPSMSvc'
    'OneSyncSvc'
    'P9RdrService'
    'PenService'
    'UdkUserSvc'
    'UserDataSvc'
    'UnistoreSvc'
    # required for the nvidia app to launch. wpnservice is not required.
    # 'MessagingService'
    # 'WpnUserService'
)

function svc_user_rm (
    [string[]] $names = $svc_user,
    [UserSvc] $state = [UserSvc]::disabled
) {
    # Disable user services. Disabled user-level services will not be created on next boot
    # Set to 3 to enable
    foreach ($name in $names) {
        if (! ($svc_user_known.contains($name))) {
            $m = "svc_rm_user: warn: user service name $name is not in the set of known user service names: $svc_user_known"
            write-host -y $m
        }
        $key = "HKLM:\System\CurrentControlSet\Services\$name"
        rprop $key 'UserServiceFlags' 'DWORD' ([int]$state)
    }
}