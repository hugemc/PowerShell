function Find-TaskSequence {
    param (
        [parameter(Mandatory = $true)]
        $TSName,
        $machine = $env:COMPUTERNAME
    )
    $VerbosePreference = "continue"
    ## Connect to Software Center
    Try {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Connecting to Software Center..."
        $SoftwareCenter = New-Object -ComObject "UIResource.UIResourceMgr"
    }
    Catch {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - Failed to connect to Software Center."
        exit 1
    }
    ## Search for Task Sequence
    Write-Verbose "$((Get-Date).ToShortTimeString()) - Searching for $TSName..."
    if ($SoftwareCenter.GetAvailableApplications() | ? { $_.PackageName -eq "$TSName" }) {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - $TSName found..."
        return $true
    }
    else {
        Write-Verbose "$((Get-Date).ToShortTimeString()) - $TSName not found..."
    }
}
