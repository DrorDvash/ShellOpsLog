# ShellOpsLog

ShellOpsLog is a lightweight command logger designed to automatically capture and log all executed commands (without their output) during engagements such as red team operations, internal pt, or whatever usage. 

The commands are saved in a CSV file with the columns **Timestamp**, **User**, **Path**, and **Command**, making it easy to use for both client deliverables and internal reviews.

## Overview

This repo contains two implementations of ShellOpsLog:

- **Bash/Zsh Version** (`ShellOpsLog.sh`):  
  Logs commands in Unix-based shells using shell hooks (**Bash**: `PROMPT_COMMAND` or **Zsh**: `preexec`).

- **PowerShell Version** (`Microsoft.PowerShell_profile.ps1`):  
  Automatically logs commands in PowerShell sessions.

Both scripts are focused on logging the executed commands (without output), so you can have a clear, CSV-ready record of your activities during engagements.

---

## ![image](https://github.com/user-attachments/assets/993e13fe-6f19-4d32-8285-d0b97440d62b) Bash/Zsh Usage
1. Place the `ShellOpsLog.sh` file in your file-system or clone the repo.
2. Adjust and add the following line to your shell startup file (e.g., `~/.bashrc` or `~/.zshrc`):
   ```bash
   source /path/to/ShellOpsLog.sh
   ```
3. Manually call or uncomment the auto-start line at the bottom of the script.
   ```bash
   $ start_operation_log
   
   # Optionally, specify a custom log directory
   $ start_operation_log ~/Projects/MyClient

   # To stop command logging, run:
   $ stop_operation_log
   ```
---

## ![image](https://github.com/user-attachments/assets/7ccae89c-b6ec-4ec3-a278-e58d83812726) PowerShell Usage
1. Copy the contents of `Microsoft.PowerShell_profile.ps1` into your profile file and save it.
   ```powershell
   notepad $PROFILE

   # In case you don't have one, create:
   New-Item -ItemType File -Path $PROFILE -Force
   ```
2. Restart powershell or open a new tab
3. Manually call or uncomment the auto-start line at the bottom of the profile.
   ```powershell
   PS> Start-OperationLog

   # Optionally, specify a custom log directory
   PS> Start-OperationLog "C:\Projects\MyClient"

   # To stop command logging, run:
   PS> Stop-OperationLog
   ```
