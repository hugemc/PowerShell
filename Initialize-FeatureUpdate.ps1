function Initialize-FeatureUpdate {
    <#
    .Synopsis
        Installs Feature Update.
    .DESCRIPTION
        Uses WMI calls to initiate updates pending in the CM client. 
    .EXAMPLE
         Install-FeatureUpdate -FUVer 2004 -Verbose
    .PARAMETER FUVer
        Feature Update version. eg 2004
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory)]
        [string]$FUVer
    )
    $VerbosePreference = "continue"
    Write-Verbose "$((Get-Date).ToShortTimeString()) - Connecting to WMI..."
    # Get FU from WMI
    $FU = Get-WmiObject -Namespace root\CCM\ClientSDK -Class CCM_SoftwareUpdate -Filter ComplianceState=0 | ? Name -like "*$FUVer*"
    $Pending = ($FU | Where-Object { $FU.EvaluationState -ne 8 } | Measure-Object).count
    if ($Pending -gt 0) {
        try {
            $MissingFU = @($FU | ForEach-Object { if ($_.ComplianceState -eq 0) { [WMI]$_.__PATH } }) 
            # Invoke CCM_SoftwareUpdatesManager.InstallUpdates 
            $InstallReturn = Invoke-WmiMethod -Class CCM_SoftwareUpdatesManager -Name InstallUpdates -ArgumentList (, $MissingFU) -Namespace root\ccm\clientsdk 
            Write-Verbose "$((Get-Date).ToShortTimeString()) - Initiated $Pending update for install"
        }
        catch {
            Write-Verbose "$((Get-Date).ToShortTimeString()) - Failed to trigger update..."
        }
    }
    else {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - No update to install..."
    }
}
