function get-IntuneComputerPoshState {
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
    $sidecarScripts = (Invoke-RestMethod -Method Get -Uri "$graph/beta/deviceManagement/deviceManagementScripts" -Headers $token).value
    $sidecarScriptsres = @()
    foreach ($SCS in $sidecarScripts) {
        $res = (Invoke-RestMethod -Method Get -Uri "$graph/beta/deviceManagement/deviceManagementScripts/$($SCS.id)/deviceRunStates?`$expand=managedDevice(`$select=deviceName,userPrincipalName)&`$filter=managedDevice/deviceName eq '$computername'" -Headers $token).value
        $res | Add-Member -name 'ScriptName' -Value $SCS.displayName -MemberType NoteProperty
        $sidecarScriptsres += $res | Where-Object {$_.managedDevice.userPrincipalName -eq $UPN}
    }
    return $sidecarScriptsres
}