$scriptName = "ScriptName"

function CheckIsActive {
    Get-WMIObject -Class Win32_Process -Filter "Name='PowerShell.EXE'" | ? { $_.commandline -like "*$scriptName.ps1*" }
}

function RunScript {
    Start-process powershell.exe -ArgumentList "& '.\$scriptName.ps1'" -WindowStyle Minimized
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
    "Script is running"
    CheckIsActive | ForEach-Object {
        $processStartDate = New-Object -Type PSCustomObject -Property @{
          'Caption'      = $_.Caption
          'CreationDate' = $_.ConvertToDateTime($_.CreationDate)
        }
    }
    
    $nowDate = Get-Date
    $minutes = (New-TimeSpan -Start $processStartDate.CreationDate -End $nowDate).TotalMinutes

    if($minutes -gt 30) {
        "Spript is running more than 30 minutes, terminating..."
        Stop-Process -Id $processID -Force
        RunScript
    }
}
