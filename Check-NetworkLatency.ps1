<#
.SYNOPSIS
    Intune Custom Compliance Discovery Script - Network Latency Check
.DESCRIPTION
    Tests latency (ping) to popular websites and reports results for Intune
    custom compliance evaluation. Each site's average latency in milliseconds
    is returned as a compressed JSON object on a single line.
    Compatible with PowerShell 5.1 (Intune management extension).
.NOTES
    Threshold: 150 ms (defined in the companion JSON policy file)
    SettingName keys must match exactly (case-sensitive) between this script
    and the JSON compliance rules file.
#>

$Sites = @{
    "Latency_google_com"     = "google.com"
    "Latency_bing_com"       = "bing.com"
    "Latency_momsmeals_com"  = "momsmeals.com"
    "Latency_microsoft_com"  = "microsoft.com"
    "Latency_amazon_com"     = "amazon.com"
    "Latency_cloudflare_com" = "cloudflare.com"
    "Latency_github_com"     = "github.com"
    "Latency_office_com"     = "office.com"
}

$PingCount = 4
$hash = @{}

foreach ($Key in $Sites.Keys) {
    $Target = $Sites[$Key]
    try {
        # Test-Connection on PS 5.1 returns Win32_PingStatus with ResponseTime (ms)
        $Ping = Test-Connection -ComputerName $Target -Count $PingCount -ErrorAction Stop
        $AvgLatency = [math]::Round(($Ping | Measure-Object -Property ResponseTime -Average).Average, 2)
        $hash[$Key] = $AvgLatency
    }
    catch {
        # If the host is unreachable, report 9999 to trigger non-compliance
        $hash[$Key] = [double]9999
    }
}

return $hash | ConvertTo-Json -Compress
