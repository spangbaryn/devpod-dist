# DevPod Installer for Windows
# Usage: iwr -useb https://raw.githubusercontent.com/spangbaryn/devpod/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "spangbaryn/devpod"
$BinaryName = "devpod.exe"
$BinaryNamePlatform = "devpod-win.exe"

# Colors for output
function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "Error: $Message" -ForegroundColor Red
    exit 1
}

# Get install directory
function Get-InstallDir {
    # Try to use %LOCALAPPDATA%\Programs first (doesn't require admin)
    $LocalPrograms = "$env:LOCALAPPDATA\Programs\DevPod"

    # Check if we can write to local programs
    if (Test-Path $LocalPrograms) {
        return $LocalPrograms
    }

    # Create directory
    try {
        New-Item -ItemType Directory -Path $LocalPrograms -Force | Out-Null
        return $LocalPrograms
    }
    catch {
        Write-ErrorMsg "Failed to create install directory: $LocalPrograms"
    }
}

# Get latest release version
function Get-LatestVersion {
    Write-Info "Fetching latest release..."

    $ReleaseUrl = "https://api.github.com/repos/$Repo/releases/latest"

    try {
        $Response = Invoke-RestMethod -Uri $ReleaseUrl -Headers @{ "User-Agent" = "DevPod-Installer" }
        $Version = $Response.tag_name

        if ([string]::IsNullOrEmpty($Version)) {
            Write-ErrorMsg "Failed to fetch latest version"
        }

        Write-Success "Latest version: $Version"
        return $Version
    }
    catch {
        Write-ErrorMsg "Failed to fetch release info: $_"
    }
}

# Download binary
function Download-Binary {
    param([string]$Version, [string]$TmpFile)

    $DownloadUrl = "https://github.com/$Repo/releases/download/$Version/$BinaryNamePlatform"

    Write-Info "Downloading from $DownloadUrl..."

    try {
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $TmpFile -UseBasicParsing

        # Verify download
        if (-not (Test-Path $TmpFile)) {
            Write-ErrorMsg "Downloaded file not found"
        }

        $FileSize = (Get-Item $TmpFile).Length
        if ($FileSize -eq 0) {
            Write-ErrorMsg "Downloaded file is empty"
        }

        Write-Success "Download complete ($FileSize bytes)"
    }
    catch {
        Write-ErrorMsg "Failed to download binary: $_"
    }
}

# Install binary
function Install-Binary {
    param([string]$TmpFile, [string]$InstallDir)

    Write-Info "Installing to $InstallDir..."

    try {
        $InstallPath = Join-Path $InstallDir $BinaryName

        # Move file
        Move-Item -Path $TmpFile -Destination $InstallPath -Force

        Write-Success "Installed successfully"
        return $InstallPath
    }
    catch {
        Write-ErrorMsg "Failed to install binary: $_"
    }
}

# Add to PATH
function Add-ToPath {
    param([string]$InstallDir)

    $UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    if ($UserPath -notlike "*$InstallDir*") {
        Write-Info "Adding to PATH..."

        try {
            $NewPath = "$UserPath;$InstallDir"
            [Environment]::SetEnvironmentVariable("PATH", $NewPath, "User")

            # Update current session
            $env:PATH = "$env:PATH;$InstallDir"

            Write-Success "Added to PATH"
            return $true
        }
        catch {
            Write-Info "Could not add to PATH automatically. Please add manually: $InstallDir"
            return $false
        }
    }

    return $false
}

# Verify installation
function Verify-Installation {
    param([string]$InstallPath)

    Write-Info "Verifying installation..."

    try {
        $VersionOutput = & $InstallPath --version 2>&1
        Write-Success "$VersionOutput installed successfully!"
        Write-Host ""
        Write-Info "Run 'devpod --help' to get started"
        Write-Info "Note: You may need to restart your terminal for PATH changes to take effect"
    }
    catch {
        Write-ErrorMsg "Installation verification failed: $_"
    }
}

# Main installation flow
function Main {
    Write-Host "========================================"
    Write-Host "  DevPod Installer for Windows"
    Write-Host "========================================"
    Write-Host ""

    $InstallDir = Get-InstallDir
    $Version = Get-LatestVersion
    $TmpFile = Join-Path $env:TEMP $BinaryNamePlatform

    try {
        Download-Binary -Version $Version -TmpFile $TmpFile
        $InstallPath = Install-Binary -TmpFile $TmpFile -InstallDir $InstallDir
        $PathAdded = Add-ToPath -InstallDir $InstallDir
        Verify-Installation -InstallPath $InstallPath

        if ($PathAdded) {
            Write-Host ""
            Write-Info "Restart your terminal to use 'devpod' command"
        }
    }
    finally {
        # Cleanup
        if (Test-Path $TmpFile) {
            Remove-Item $TmpFile -Force -ErrorAction SilentlyContinue
        }
    }
}

Main
