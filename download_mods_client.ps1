$ProgressPreference = 'SilentlyContinue'

$modsListUrl = "https://raw.githubusercontent.com/0000xFFFF/minecraft-mods/refs/heads/master/mods_client.txt"
$tempDir = [System.IO.Path]::GetTempPath()
$tempFile = Join-Path $tempDir "mods_client.txt"

Write-Host "Fetching mods list..."
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($modsListUrl, $tempFile)
} 
catch {
    Write-Host "Error: Failed to download mods list from $modsListUrl" -ForegroundColor Red
    exit 1
}

Write-Host "Starting downloads..."

foreach ($line in Get-Content $tempFile) {
    $line = $line.Trim()
    
    # Skip empty lines or comments
    if (-not $line -or $line.StartsWith("#")) { continue }

    try {
        $uri = [System.Uri]$line
        $filename = [System.IO.Path]::GetFileName($uri.AbsolutePath)
        $filename = [System.Net.WebUtility]::UrlDecode($filename)

        Write-Host "Downloading: $filename"
        $webClient.DownloadFile($line, $filename)
        Write-Host "  [OK] Saved to $filename" -ForegroundColor Green
    } 
    catch {
        Write-Host "  [ERROR] Failed to download: $_" -ForegroundColor Red
    }
}

# Clean up temp file
if (Test-Path $tempFile) { Remove-Item $tempFile }

Write-Host "Done!"
