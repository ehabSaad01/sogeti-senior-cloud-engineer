<# 
Purpose: Minimal environment check for Azure PowerShell
Notes:
- Uses clear, explicit commands
- Exits with non-zero code on failure (for CI)
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Info([string]$msg) { Write-Host $msg }

# 1) Ensure Az module is available
if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
    Info "Az.Accounts is not installed."
    Info "Install: Install-Module Az -Scope CurrentUser"
    exit 127
}

# 2) Ensure user is logged in
try {
    $ctx = Get-AzContext -ErrorAction Stop
} catch {
    Info "You are not logged in. Run: Connect-AzAccount"
    exit 1
}

# 3) Print current subscription summary
Info "Current subscription:"
$sub = Get-AzContext | Select-Object -ExpandProperty Subscription
$ten = Get-AzContext | Select-Object -ExpandProperty Tenant
"{0}`t{1}`t{2}" -f $sub.Name, $sub.Id, $ten.Id | Write-Host

Info "Environment check completed."
