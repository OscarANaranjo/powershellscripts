# Script: delete_old_versions.ps1
# Purpose: Delete excess file versions across all SharePoint Online sites (keeps 2 major, 1 minor)
# Technologies: PowerShell, SharePoint Online Management Shell
# Business Impact: Reduces storage footprint by trimming version history; supports governance and cost control
# Delete previous versions of Files all Kallman sharepoint sites. 
# Connect to SharePoint Online
Connect-SPOService -Url https://kallmanworldwideinc-admin.sharepoint.com

# Get all site collections
$sites = Get-SPOSite -Limit All

# Export the site URLs to a CSV file
$csvPath = Join-Path -Path (Get-Location) -ChildPath "KallmanSharepointSites.csv"
$sites | Select-Object -Property Url | Export-Csv -Path $csvPath -NoTypeInformation

# Loop through each site and run the version delete job
foreach ($site in $sites) {
    New-SPOSiteFileVersionBatchDeleteJob -Identity $site.Url -MajorVersionLimit 2 -MajorWithMinorVersionsLimit 1
    Write-Output "Started version delete job for site: $($site.Url)"
}

Write-Output "All jobs have been started. Site URLs have been exported to $csvPath."
