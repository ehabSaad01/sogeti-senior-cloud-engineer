# ============================================================
# File: scripts/day04-compute-ps.ps1
# Purpose: Day04 - Secure VM baseline with UAMI + DCR association (PowerShell)
# Notes:
# - Replace VNet/Subnet names if different from Day03.
# - Assumes DCR "dcr-vm04" and LAW "law-dev-weu" already exist (Portal).
# - Secure-by-default: no Public IP, SSH-only.
# ============================================================

$ErrorActionPreference = "Stop"

# 1) Constants
$rg  = "rg-day04-compute"
$loc = "westeurope"
$vnetName   = "vnet03weu"       # change if different
$subnetName = "subnet03weu"     # change if different
$nicName    = "nic04weu"
$vmName     = "vm04weu"
$uamiName   = "uami04weu"
$dcrName    = "dcr-vm04"
$linuxUser  = "azureuser"
$sshKeyData = "<your_ssh_public_key>"

# 2) RG
New-AzResourceGroup -Name $rg -Location $loc -ErrorAction SilentlyContinue | Out-Null

# 3) UAMI
$uami = New-AzUserAssignedIdentity -ResourceGroupName $rg -Name $uamiName -Location $loc

# 4) VNet/Subnet
$vnet   = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $rg
$subnet = $vnet.Subnets | Where-Object { $_.Name -eq $subnetName }

# 5) NIC without Public IP
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $rg -Location $loc -SubnetId $subnet.Id

# 6) Build VM config (Linux, SSH only, no Public IP)
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_B2s" |
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential (Get-Credential -Message "Enter a temporary credential; password auth will be disabled") -DisablePasswordAuthentication |
    Add-AzVMSshPublicKey -KeyData $sshKeyData -Path "/home/$linuxUser/.ssh/authorized_keys" |
    Set-AzVMSourceImage -PublisherName "Canonical" -Offer "0001-com-ubuntu-server-jammy" -Skus "22_04-lts" -Version "latest" |
    Add-AzVMNetworkInterface -Id $nic.Id

# 7) Create VM
New-AzVM -ResourceGroupName $rg -Location $loc -VM $vmConfig

# 8) Attach UAMI
$vm = Get-AzVM -Name $vmName -ResourceGroupName $rg
$vm = Set-AzVMIdentity -VM $vm -Type UserAssigned -IdentityIds $uami.Id
Update-AzVM -ResourceGroupName $rg -VM $vm

# 9) Least-privilege RBAC (Reader at RG scope)
New-AzRoleAssignment -ObjectId $uami.PrincipalId -RoleDefinitionName "Reader" -Scope (Get-AzResourceGroup -Name $rg).ResourceId | Out-Null

# 10) Associate existing DCR to VM
$dcr = Get-AzDataCollectionRule -ResourceGroupName $rg -Name $dcrName
New-AzDataCollectionRuleAssociation -Name "dcrassoc-vm04" -ResourceUri $vm.Id -DataCollectionRuleId $dcr.Id | Out-Null
