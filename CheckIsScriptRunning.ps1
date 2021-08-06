$scriptName = "ScriptName"

function CheckIsActive {
    Get-WMIObject -Class Win32_Process -Filter "Name='PowerShell.EXE'" | ? { $_.commandline -like "*$scriptName.ps1" }
}

function RunScript {
    Start-process powershell.exe -ArgumentList "& '.\$scriptName.ps1'"
    exit
}

if ($null -eq (CheckIsActive)) {
    Write-host "Missing script process"
    sleep -s 5
    Write-host "Recheck"
    
    if ($null -eq (CheckIsActive)) { 
        Write-host "Missing script process"
        Write-host "Starting script"
        RunScript 
    }
    else {
        Write-host "Script started"
    }
}
else {
    Write-host "Script is running"
    $processStartDate = CheckIsActive | % { $_.ConvertToDateTime( $_.CreationDate ) } | Get-Date
    $processID = (CheckIsActive).ProcessID
    $nowDate = Get-Date

    if($((New-TimeSpan -Start $processStartDate -End $nowDate).TotalMinutes) -gt 30) {
        Write-host "Spript is running more than 30 minutes, terminating..."
        Stop-Process -Id $processID -Force
        RunScript
    }
}