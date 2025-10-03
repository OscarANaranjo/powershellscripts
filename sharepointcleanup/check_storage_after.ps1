# Script: check_storage_after.ps1
# Purpose: Capture storage usage across all SharePoint Online sites after running version cleanup
# Technologies: PowerShell, SharePoint Online Management Shell
# Business Impact: Confirms effectiveness of cleanup and provides metrics for IT reporting
# Suppress confirmation prompts
$ConfirmPreference = 'None'

# Connect to SharePoint Online
Connect-SPOService -Url https://kallmanworldwideinc-admin.sharepoint.com

# Get all site collections
$sites = Get-SPOSite -Limit All

# Initialize an array to store the results
$results = @()
$totalStorageAfter = 0

# Function to get storage usage
function Get-SiteStorageUsage($siteUrl) {
    $site = Get-SPOSite -Identity $siteUrl
    $totalStorageAfter += $site.StorageUsageCurrent
    return [PSCustomObject]@{
        Url = $site.Url
        StorageUsageAfter = $site.StorageUsageCurrent
    }
}

# Get storage usage after running the delete job
foreach ($site in $sites) {
    $results += Get-SiteStorageUsage -siteUrl $site.Url
}

# Add total storage usage to the results
$results += [PSCustomObject]@{
    Url = "Total"
    StorageUsageAfter = $totalStorageAfter
}

# Export the results to a CSV file
$csvPath = Join-Path -Path (Get-Location) -ChildPath "KallmanSharepointSites_After.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation

Write-Output "Storage usage after deletion has been exported to $csvPath."
