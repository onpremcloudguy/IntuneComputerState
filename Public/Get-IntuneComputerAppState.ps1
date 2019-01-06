function get-IntuneComputerAppState {
    param(
        # Computer Name
        [Parameter(Mandatory)]
        [string]
        $Computername,
        # UPN
        [Parameter(Mandatory)]
        [string]
        $UPN,
        [Parameter(Mandatory)]
        [Object]
        $token
    )
    $graph = "https://graph.microsoft.com"
    $MobileApps = (Invoke-RestMethod -Method Get -Uri "$graph/Beta/deviceAppManagement/mobileApps" -Headers $token).value
    $MobileAppsres = @()
    foreach ($SCS in $MobileApps) {
        $res = (Invoke-RestMethod -Method Get -Uri "$graph/beta/deviceAppManagement/mobileApps/$($SCS.id)/deviceStatuses?`$filter=deviceName eq '$computername'" -Headers $token).value
        $res | Add-Member -name 'Application' -Value $SCS.displayName -MemberType NoteProperty
        $MobileAppsres += $res | Where-Object {$_.userPrincipalName -eq $UPN}
    }
    return $MobileAppsres
}