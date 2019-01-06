function get-IntuneComputerState {
    param(
        # Computer Name
        [Parameter(Mandatory)]
        [string]
        $UPN,
        [Parameter(Mandatory = $false)]
        [System.Net.Mail.MailAddress]$userEmail = $intuneCred.UserName,
        [ValidateSet("NewInteractive", "AutoInteractive", "NonInteractive")]
        [string]$authMethod = "NonInteractive"
    )
    switch ($authMethod) {
        "NewInteractive" {
            $Script:token = Get-AuthInteractive -userEmail $userEmail -clientId "d1ddf0e4-d672-4dae-b554-9d5bdfd93547" -promptBehaviour Always
            Write-Verbose $token
            break
        }
        "AutoInteractive" {
            $Script:token = Get-AuthInteractive -userEmail $userEmail -clientId "d1ddf0e4-d672-4dae-b554-9d5bdfd93547" -promptBehaviour Auto
            Write-Verbose $token
            break
        }
        "NonInteractive" {
            if (!($Script:intuneCred)) {
                $Script:intuneCred = Get-Credential -UserName $userEmail -Message "Please enter credentials to continue.."
            }
            $Script:token = Get-AuthNonInteractive -credential $Script:intuneCred -clientId "d1ddf0e4-d672-4dae-b554-9d5bdfd93547" -resourceURL "https://graph.microsoft.com/";
            Write-Verbose $token
            break
        }
        default {
            Write-Warning "Auth Method doesn't match expected value.."
        }
    }
    $devices = Get-IntuneComputersFromUPN -upn $UPN -token $token
    $devres = @()
    foreach($d in $devices)
    {
        $posh = get-IntuneComputerPoshState -Computername $d.devicename -token $token -upn $UPN
        $apps = get-IntuneComputerAppState -Computername $d.devicename -token $token -upn $UPN
        $configpol = get-IntuneComputerConfiguration -Computername $d.devicename -token $token -upn $UPN
        $compol = get-IntuneComputerCompliance -Computername $d.devicename -token $token -upn $UPN
        
        $d | Add-Member -name "PowerShellScripts" -Value $posh -MemberType NoteProperty
        $d | Add-Member -Name "Applications" -value $apps -MemberType NoteProperty
        $d | Add-Member -Name "CompliancePolicies" -Value $compol -MemberType NoteProperty
        $d | Add-Member -Name "ConfigurationPolicies" -Value $configpol -MemberType NoteProperty
        $devres += $d
    }
    Clear-Host
    foreach ($dr in $devres)
    {
        write-host "--------------------------------------------------------------`nIntune Audit for computer $($dr.deviceName)`n--------------------------------------------------------------"
        Write-Host " ++ Computer Name : $($dr.deviceName)"
        Write-host " ++ Serial Number : $($dr.serialNumber)"
        Write-Host " ++ Enrollment Date : $($dr.enrolledDateTime)"
        write-host " ++ Device Model : $($dr.model)"
        write-host " ++ Device Manufacturer : $($dr.manufacturer)"
        Write-Host " ++ Encrypted : $($dr.isEncrypted)"
        Write-Host " ++ Status of PowerShell Scripts"
        $dr.PowerShellScripts | Select-Object ScriptName, RunState | Format-Table | Out-String | Where-Object {Write-Host $_}
        Write-Host " ++ Status of Applications"
        $dr.Applications | Select-Object Application, installState | Format-Table | Out-String | Where-Object {Write-Host $_}
        Write-Host " ++ Status of Configuration Policies"
        $dr.ConfigurationPolicies | Select-Object ConfigurationPolicyName, status | Format-Table | Out-String | Where-Object {Write-Host $_}
        Write-Host " ++ Status of Compliance Policies"
        $dr.CompliancePolicies | Select-Object CompliancePolicyName, status | Format-Table | Out-String | Where-Object {Write-Host $_}
    }
    return $devres
}