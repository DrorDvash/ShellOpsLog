<#
    ShellOpsLog - PowerShell Command Logger
    ----------------------------------------
    - Logs all executed commands with timestamps into a CSV.
    - Saves logs to `C:\Users\<User>\Desktop\OperationLogs\` 
        or manually define a custom path where to save the output file
        `Start-OperationLog C:\Projects\MyClient`

    ## Usage ##
    - Add this script to $PROFILE (`notepad $PROFILE`)  
    - Restart PowerShell  
    - Run `Start-OperationLog` to begin logging or uncomment the last line

    ## Credits ##  
    - Created by DrorDvash
    - Repo: https://github.com/DrorDvash/ShellOpsLog
#>

# Save the existing prompt function if it exists; otherwise, use a default prompt
if (Get-Command prompt -CommandType Function -ErrorAction SilentlyContinue) {
    $global:OriginalPrompt = (Get-Command prompt -CommandType Function).ScriptBlock
} else {
    $global:OriginalPrompt = {
        # Default fallback prompt
        "PS $($executionContext.SessionState.Path.CurrentLocation)> "
    }
}

# Define a new prompt function that logs commands then calls the original prompt
function prompt {
    # Log command if logging is active
    if ($global:OperationLogActive -and $global:OperationLogPath) {
        $lastCommand = Get-History -Count 1 -ErrorAction SilentlyContinue
        if ($lastCommand) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $username = $env:USERNAME
            $path = (Get-Location).Path

            [PSCustomObject]@{
                Timestamp = $timestamp
                User      = $username
                Path      = $path
                Command   = $lastCommand.CommandLine
            } | Export-Csv -Path $global:OperationLogPath -Append -NoTypeInformation -Force
        }
    }

    # Call the original prompt function (existing or default)
    & $global:OriginalPrompt
}

# Function to start logging commands
function Start-OperationLog {
    param(
        [string]$LogDir = "$env:USERPROFILE\Desktop\OperationLogs",
        [switch]$AutoStart
    )

    if ($global:OperationLogActive) { 
        Write-Host "Logging already active: $global:OperationLogPath" -ForegroundColor Yellow
        return 
    }

    # Create the log directory if needed
    $null = New-Item -Path $LogDir -ItemType Directory -Force -ErrorAction SilentlyContinue

    # Generate log file path based on current date
    $LogDate = Get-Date -Format "yyyy-MM-dd"
    $global:OperationLogPath = "$LogDir\operation_log_$LogDate.csv"
    
    if (-not $AutoStart) {
        $response = Read-Host "Start logging this window to '$global:OperationLogPath'? [Y/n]"
        if ($response -notmatch '^[yY]?$') { 
            Write-Host "Logging skipped" -ForegroundColor Yellow
            return 
        }
    }

    $global:OperationLogActive = $true
    Write-Host "Command logging active: $global:OperationLogPath" -ForegroundColor Green
}

# Function to stop logging commands
function Stop-OperationLog {
    if ($global:OperationLogActive) {
        $global:OperationLogActive = $false
        Write-Host "Command logging stopped: $global:OperationLogPath" -ForegroundColor Yellow
        $global:OperationLogPath = $null
    } else {
        Write-Host "No active logging session to stop" -ForegroundColor Yellow
    }
}

# Optionally auto-start logging (remove or comment out if not desired)
# Start-OperationLog #-AutoStart
