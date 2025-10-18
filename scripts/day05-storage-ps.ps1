# Day05 — Secure Storage Baseline (PowerShell, Az modules)
# Goal: StorageV2 + Private Endpoint (blob) + Diagnostics + RBAC (UAMI) + Data Protection
# NOTE: Replace all <PLACEHOLDER> values before running.
# Comments are in English. Long option names only.

# --- 0) Login and subscription (uncomment if needed) ---
# Connect-AzAccount
# Select-AzSubscription -SubscriptionId "<SUBSCRIPTION_ID>"

# --- 1) Resource Group ---
New-AzResourceGroup `
  -Name "rg-day05-storage" `
  -Location "westeurope" `
  -Tag @{ env="dev"; day="05"; security="rbac-first" } `
  | Out-Null

# --- 2) Storage Account (secure-by-default) ---
$sa = New-AzStorageAccount `
  -ResourceGroupName "rg-day05-storage" `
  -Name "stday05weu" `
  -Location "westeurope" `
  -SkuName "Standard_LRS" `
  -Kind "StorageV2" `
  -EnableHttpsTrafficOnly:$true `
  -MinimumTlsVersion "TLS1_2"

# Deny public network, disable shared key, disable blob public access
Set-AzStorageAccount `
  -ResourceGroupName "rg-day05-storage" `
  -Name "stday05weu" `
  -DefaultAction "Deny" `
  -AllowBlobPublicAccess:$false `
  -DisableSharedKeyAccess:$true `
  | Out-Null

# --- 3) Data Protection (Versioning + Soft delete) ---
Set-AzStorageBlobServiceProperty `
  -ResourceGroupName "rg-day05-storage" `
  -AccountName "stday05weu" `
  -EnableVersioning:$true `
  -EnableDeleteRetentionPolicy:$true `
  -DeleteRetentionDays 14 `
  -EnableContainerDeleteRetentionPolicy:$true `
  -ContainerDeleteRetentionDays 14 `
  | Out-Null

# --- 4) Diagnostics to Log Analytics (LAW) ---
$saId = (Get-AzStorageAccount -ResourceGroupName "rg-day05-storage" -Name "stday05weu").Id
$lawId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName "<RG_OF_LAW_DAY03>" -Name "law-dev-weu").ResourceId

# Categories: StorageRead, StorageWrite, StorageDelete, Transaction; Metrics: AllMetrics
Set-AzDiagnosticSetting `
  -Name "ds-stday05weu" `
  -ResourceId $saId `
  -WorkspaceId $lawId `
  -Enabled:$true `
  -Category "StorageRead","StorageWrite","StorageDelete","Transaction" `
  -MetricCategory "AllMetrics" `
  | Out-Null

# --- 5) Private DNS Zone + VNet link (Day03 VNet) ---
# Create zone if missing
$dnsZone = Get-AzPrivateDnsZone -Name "privatelink.blob.core.windows.net" -ResourceGroupName "rg-day05-storage" -ErrorAction SilentlyContinue
if (-not $dnsZone) {
  $dnsZone = New-AzPrivateDnsZone -Name "privatelink.blob.core.windows.net" -ResourceGroupName "rg-day05-storage"
}

# Link Day03 VNet to the zone
$day03VnetId = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_OF_VNET_DAY03>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME_DAY03>"
$existingLink = Get-AzPrivateDnsVirtualNetworkLink -ZoneName "privatelink.blob.core.windows.net" -ResourceGroupName "rg-day05-storage" -ErrorAction SilentlyContinue | Where-Object { $_.VirtualNetworkId -eq $day03VnetId }
if (-not $existingLink) {
  New-AzPrivateDnsVirtualNetworkLink `
    -ZoneName "privatelink.blob.core.windows.net" `
    -ResourceGroupName "rg-day05-storage" `
    -Name "link-day03" `
    -VirtualNetworkId $day03VnetId `
    -EnableRegistration:$false `
    | Out-Null
}

# --- 6) Private Endpoint (blob) + DNS zone group ---
$peSubnetId = "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_OF_VNET_DAY03>/providers/Microsoft.Network/virtualNetworks/<VNET_NAME_DAY03>/subnets/<SUBNET_NAME_FOR_PE>"
$plsId = $saId
$plsConn = New-AzPrivateLinkServiceConnection `
  -Name "pe-stday05weu-blob-conn" `
  -PrivateLinkServiceId $plsId `
  -GroupId "blob"

$pe = New-AzPrivateEndpoint `
  -Name "pe-stday05weu-blob" `
  -ResourceGroupName "rg-day05-storage" `
  -Location "westeurope" `
  -Subnet $peSubnetId `
  -PrivateLinkServiceConnection $plsConn

# Bind PE to Private DNS zone (zone group "default")
$zoneResId = $dnsZone.ResourceId
$zoneCfg = New-AzPrivateDnsZoneConfig -Name "privatelink.blob.core.windows.net" -PrivateDnsZoneId $zoneResId
New-AzPrivateDnsZoneGroup `
  -Name "default" `
  -ResourceGroupName "rg-day05-storage" `
  -PrivateEndpointName "pe-stday05weu-blob" `
  -PrivateDnsZoneConfig $zoneCfg `
  | Out-Null

# --- 7) RBAC: Grant UAMI on blobs data plane ---
$uamiPrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName "<RG_OF_UAMI_DAY04>" -Name "uami04weu").PrincipalId
New-AzRoleAssignment `
  -ObjectId $uamiPrincipalId `
  -RoleDefinitionName "Storage Blob Data Contributor" `
  -Scope $saId `
  | Out-Null

Write-Output "Day05 PowerShell setup completed."
