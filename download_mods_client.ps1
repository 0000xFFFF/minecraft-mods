
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ModsListUrls = @(
    "https://raw.githubusercontent.com/0000xFFFF/minecraft-mods/refs/heads/master/list_mods_both.txt",
    "https://raw.githubusercontent.com/0000xFFFF/minecraft-mods/refs/heads/master/list_mods_client_only.txt"
)

$SkipExisting = $true
$DownloadDir = (Get-Location).Path

$tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "minecraft_mods_list.txt"

foreach ($url in $ModsListUrls) {
    Write-Host "`nFetching mods list from $url..." -ForegroundColor Cyan

    try {
        Invoke-WebRequest -Uri $url -OutFile $tempFile -ErrorAction Stop
    }
    catch {
        Write-Host "[ERROR] Failed to fetch mod list." -ForegroundColor Red
        Write-Host $_.Exception.ToString() -ForegroundColor DarkRed
        continue
    }

    foreach ($line in Get-Content $tempFile) {
        $line = $line.Trim()

        if (-not $line -or $line.StartsWith("#")) {
            continue
        }

        try {
            $uri = [System.Uri]$line

            if (-not $uri.IsAbsoluteUri -or $uri.Scheme -notin @("http", "https")) {
                throw "Not a valid HTTP/HTTPS URL: $line"
            }

            $filename = [System.IO.Path]::GetFileName(
                [System.Net.WebUtility]::UrlDecode($uri.AbsolutePath)
            )

            if ([string]::IsNullOrWhiteSpace($filename)) {
                throw "Could not extract a filename from URL: $line"
            }

            # Replace characters Windows does not allow in filenames.
            foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
                $filename = $filename.Replace([string]$char, "_")
            }

            $destinationPath = Join-Path $DownloadDir $filename

            if ($SkipExisting -and (Test-Path -LiteralPath $destinationPath)) {
                Write-Host "[SKIP] $filename already exists." -ForegroundColor Yellow
                continue
            }

            Write-Host "[DOWNLOAD] $filename" -ForegroundColor Cyan

            Invoke-WebRequest `
                -Uri $uri.AbsoluteUri `
                -OutFile $destinationPath `
                -ErrorAction Stop

            Write-Host "[OK] Saved to $destinationPath" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERROR] Failed to download: $line" -ForegroundColor Red
            Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor DarkRed

            if ($_.Exception.InnerException) {
                Write-Host "Details: $($_.Exception.InnerException.Message)" `
                    -ForegroundColor DarkYellow
            }

            if ($destinationPath -and
                (Test-Path -LiteralPath $destinationPath) -and
                -not $SkipExisting) {
                Remove-Item -LiteralPath $destinationPath -Force `
                    -ErrorAction SilentlyContinue
            }
        }
    }
}

Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
Write-Host "`nDone!" -ForegroundColor Green

