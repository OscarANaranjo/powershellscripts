# Script: check_storage_before.ps1
# Purpose: Capture storage usage across all SharePoint Online sites before running version cleanup
# Technologies: PowerShell, SharePoint Online Management Shell
# Business Impact: Establishes baseline metrics to quantify space savings after cleanup
# Suppress confirmation prompts
$ConfirmPreference = 'None'

# Connect to SharePoint Online
Connect-SPOService -Url https://kallmanworldwideinc-admin.sharepoint.com

# Get all site collections
$sites = Get-SPOSite -Limit All

# Initialize an array to store the results
$results = @()
$totalStorageBefore = 0

# Function to get storage usage
function Get-SiteStorageUsage($siteUrl) {
    $site = Get-SPOSite -Identity $siteUrl
    $totalStorageBefore += $site.StorageUsageCurrent
    return [PSCustomObject]@{
        Url = $site.Url
        StorageUsageBefore = $site.StorageUsageCurrent
    }
}

# Get storage usage before running the delete job
foreach ($site in $sites) {
    $results += Get-SiteStorageUsage -siteUrl $site.Url
}

# Add total storage usage to the results
$results += [PSCustomObject]@{
    Url = "Total"
    StorageUsageBefore = $totalStorageBefore
}

# Export the results to a CSV file
$csvPath = Join-Path -Path (Get-Location) -ChildPath "KallmanSharepointSites_Before.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

Write-Output "Storage usage before deletion has been exported to $csvPath."

# Run the version delete job for each site
foreach ($site in $sites) {
    New-SPOSiteFileVersionBatchDeleteJob -Identity $site.Url -MajorVersionLimit 2 -MajorWithMinorVersionsLimit 1
    Write-Output "Started version delete job for site: $($site.Url)"
}

Write-Output "All jobs have been started."
