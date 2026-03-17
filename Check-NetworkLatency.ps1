<#
.SYNOPSIS
    Intune Custom Compliance Script - Network Latency Check
.DESCRIPTION
    Tests latency (ping) to popular websites and reports results for Intune
    custom compliance evaluation. Each site's average latency in milliseconds
    is returned as a JSON object.
.NOTES
    Threshold: 150 ms (defined in the companion JSON policy file)
#>

$Sites = @(
    "google.com",
    "bing.com",
    "momsmeals.com",
    "microsoft.com",
    "amazon.com",
    "cloudflare.com",
    "github.com",
    "office.com"
)

$PingCount = 4
$Results = @{}

foreach ($Site in $Sites) {
    # Sanitize site name for use as a JSON key (replace dots with underscores)
    $Key = "Latency_" + ($Site -replace '\.', '_')

    try {
        $Ping = Test-Connection -ComputerName $Site -Count $PingCount -TimeoutSeconds 5 -ErrorAction Stop

        # Calculate average round-trip time in milliseconds
        $AvgLatency = [math]::Round(($Ping | Measure-Object -Property Latency -Average).Average, 2)
        $Results[$Key] = $AvgLatency
    }
    catch {
        # If the host is unreachable, report max value to trigger non-compliance
        $Results[$Key] = 9999
    }
}

# Intune expects the detection script to return a single JSON string to stdout
$Results | ConvertTo-Json -Compress
