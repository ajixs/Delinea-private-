# ============================================================
# CRL Mirror Downloader
# Download -> Validate -> Delete Old CRL -> Move New CRL
# Retry download 3x
# ============================================================

$Url = "http://cdp.geotrust.com/GeoTrustTLSRSACAG1.crl"

$BasePath = $PSScriptRoot

$Dest = Join-Path $BasePath "GeoTrustTLSRSACAG1.crl"
$Temp = Join-Path $BasePath "GeoTrustTLSRSACAG1.crl.tmp"
$Log  = Join-Path $BasePath "crl-download.log"

$MaxRetry = 3
$RetryDelaySeconds = 10


# ============================================================
# LOG FUNCTION
# ============================================================

function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    "$Timestamp [$Level] $Message" |
        Out-File -FilePath $Log -Append -Encoding utf8
}


# ============================================================
# START
# ============================================================

try {

    Write-Log "========================================"
    Write-Log "Starting CRL download"
    Write-Log "URL: $Url"


    # --------------------------------------------------------
    # Hapus temporary file lama jika ada
    # --------------------------------------------------------

    if (Test-Path $Temp) {
        Remove-Item `
            -Path $Temp `
            -Force `
            -ErrorAction SilentlyContinue
    }


    # --------------------------------------------------------
    # Download CRL dengan retry 3x
    # --------------------------------------------------------

    $DownloadSuccess = $false

    for ($Attempt = 1; $Attempt -le $MaxRetry; $Attempt++) {

        try {

            Write-Log "Download attempt $Attempt of $MaxRetry"

            Invoke-WebRequest `
                -Uri $Url `
                -OutFile $Temp `
                -UseBasicParsing `
                -TimeoutSec 60 `
                -ErrorAction Stop

            $DownloadSuccess = $true

            Write-Log "Download attempt $Attempt successful." "SUCCESS"

            break
        }
        catch {

            Write-Log "Download attempt $Attempt failed. Error: $($_.Exception.Message)" "WARNING"

            if (Test-Path $Temp) {
                Remove-Item $Temp -Force -ErrorAction SilentlyContinue
            }

            if ($Attempt -lt $MaxRetry) {

                Write-Log "Waiting $RetryDelaySeconds seconds before retry..."

                Start-Sleep -Seconds $RetryDelaySeconds
            }
        }
    }


    # --------------------------------------------------------
    # Jika semua retry gagal
    # --------------------------------------------------------

    if (-not $DownloadSuccess) {
        throw "CRL download failed after $MaxRetry attempts."
    }


    # --------------------------------------------------------
    # Pastikan temporary file berhasil dibuat
    # --------------------------------------------------------

    if (-not (Test-Path $Temp)) {
        throw "Downloaded file was not created."
    }


    # --------------------------------------------------------
    # Cek ukuran file
    # --------------------------------------------------------

    $FileSize = (Get-Item $Temp).Length

    if ($FileSize -le 0) {
        throw "Downloaded CRL file is empty."
    }


    # --------------------------------------------------------
    # Validasi file CRL
    # --------------------------------------------------------

    & certutil.exe -dump $Temp *> $null

    if ($LASTEXITCODE -ne 0) {
        throw "Downloaded file is not a valid CRL."
    }

    Write-Log "Downloaded CRL validation successful."


    # --------------------------------------------------------
    # Hapus CRL lama jika sudah ada
    # --------------------------------------------------------

    if (Test-Path $Dest) {

        Remove-Item `
            -Path $Dest `
            -Force `
            -ErrorAction Stop

        Write-Log "Old CRL file deleted."
    }


    # --------------------------------------------------------
    # Pindahkan CRL baru
    # --------------------------------------------------------

    Move-Item `
        -Path $Temp `
        -Destination $Dest `
        -Force `
        -ErrorAction Stop


    # --------------------------------------------------------
    # SUCCESS
    # --------------------------------------------------------

    Write-Log "CRL download successful." "SUCCESS"
    Write-Log "File: $Dest" "SUCCESS"
    Write-Log "Size: $FileSize bytes" "SUCCESS"

    exit 0
}


# ============================================================
# ERROR HANDLING
# ============================================================

catch {

    Write-Log "CRL download failed." "ERROR"
    Write-Log "Error: $($_.Exception.Message)" "ERROR"

    if (Test-Path $Temp) {

        Remove-Item `
            -Path $Temp `
            -Force `
            -ErrorAction SilentlyContinue

        Write-Log "Temporary file removed."
    }

    exit 1
}
