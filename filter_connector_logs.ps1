<#
    Script Name    : FilterLogs.ps1
    Description    : This script extracts and combines specific lines from log files located in the current working directory.
                     It is designed to help filter log files for Self-Hosted Integration by including only the lines that contain 
                     "ApiProxyCloudRpc" or "RpcHostEndpointRegistrar".
    Author         : Jared Brodsky 
    Date Created   : 2025-04-07
    Version        : 1.0
    Usage          : 
                     1. Place this script in the directory where your log files reside (e.g., log.txt, log.txt.1, log.txt.2, etc.).
                     2. Open PowerShell and navigate to that directory.
                     3. Run the script; it will prompt you to select the type of logs to extract.
                     4. The combined filtered output will be saved as "combined_filtered_logs.txt" in the same directory.
    Dependencies :   PowerShell 5.1 or later.
    Notes          : 
                     - The script currently supports only one log type option (Self-Hosted Integration). Additional options can be added using the switch statement.
                     - Ensure that "combined_filtered_logs.txt" is not open in any application before running the script.
#>

# Prompt the user for the log type selection
Write-Host "Select the type of logs you want to extract:"
Write-Host "1. Self-Hosted Integration"
$userChoice = Read-Host "Enter your choice number"

# Use a switch statement to handle future expansion of log types
switch ($userChoice) {
    "1" {
        # For Self-Hosted Integration, include lines that match either of these patterns.
        $matchPattern = "ApiProxyCloudRpc|RpcHostEndpointRegistrar"
    }
    default {
        Write-Error "Invalid selection. Exiting."
        exit 1
    }
}

# Set the input directory to the current working directory
$inputDirectory = (Get-Location).Path

# Define the output file (it will be created in the current directory)
$outputFile = "combined_filtered_logs.txt"

# Remove the output file if it already exists, ensuring it's not open elsewhere
if (Test-Path $outputFile) {
    try {
        Remove-Item $outputFile -Force -ErrorAction Stop
    } catch {
        Write-Error "Error: Cannot remove $outputFile. Please close any programs using the file and try again."
        exit 1
    }
}

# Create an empty output file
New-Item -ItemType File -Path $outputFile -Force | Out-Null

# Retrieve all files matching *.txt* (e.g., log.txt, log.txt.1, etc.) in the current directory
$logFiles = Get-ChildItem -Path $inputDirectory -Filter *.txt*
if ($logFiles.Count -eq 0) {
    Write-Error "No log files matching pattern '*.txt*' found in '$inputDirectory'."
    exit 1
}

# Process each log file and append matching lines to the output file
foreach ($file in $logFiles) {
    try {
        # Get the content of the file, filter lines matching the specified pattern, and append to the output file
        Get-Content $file.FullName | Where-Object { $_ -match $matchPattern } | Out-File -FilePath $outputFile -Append
        Write-Host "Processed $($file.FullName)"
    } catch {
        Write-Error "Error processing file $($file.FullName): $_"
    }
}

Write-Host "Combined matching output saved to $outputFile"
