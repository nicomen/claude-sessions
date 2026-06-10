#Requires -Version 5.1
<#
.SYNOPSIS
    Installs saisons
.DESCRIPTION
    Downloads the saisons Perl script and installs it to a directory in PATH.
    Installs Strawberry Perl via winget if Perl is not found.
#>
param(
    [string]$InstallDir = "$env:USERPROFILE\bin"
)

$ErrorActionPreference = "Stop"
$ScriptUrl = "https://raw.githubusercontent.com/nicomen/saisons/main/saisons"

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

# Check for Perl
if (-not (Test-Command "perl")) {
    Write-Host "Perl not found. Attempting to install Strawberry Perl via winget..." -ForegroundColor Yellow

    if (Test-Command "winget") {
        winget install StrawberryPerl.StrawberryPerl --accept-source-agreements --accept-package-agreements
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("PATH","User")
        if (-not (Test-Command "perl")) {
            Write-Host "Perl installed. Please restart your terminal and run this script again." -ForegroundColor Cyan
            exit 0
        }
    } else {
        Write-Host "winget not available. Please install Strawberry Perl manually:" -ForegroundColor Red
        Write-Host "  https://strawberryperl.com/"
        Write-Host ""
        Write-Host "Or via scoop:  scoop install perl"
        Write-Host "Or via choco:  choco install strawberryperl"
        exit 1
    }
}

$perlVersion = & perl -e "print $^V"
Write-Host "Perl $perlVersion found." -ForegroundColor Green

# Create install dir
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir | Out-Null
    Write-Host "Created $InstallDir"
}

# Add to user PATH if not already there
$userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$InstallDir*") {
    [System.Environment]::SetEnvironmentVariable("PATH", "$userPath;$InstallDir", "User")
    $env:PATH += ";$InstallDir"
    Write-Host "Added $InstallDir to your PATH."
}

# Download script
$dest = Join-Path $InstallDir "saisons"
Write-Host "Downloading saisons to $dest ..."
Invoke-WebRequest -Uri $ScriptUrl -OutFile $dest -UseBasicParsing

# Create a .cmd wrapper so it's callable without typing "perl"
$wrapper = Join-Path $InstallDir "saisons.cmd"
Set-Content -Path $wrapper -Value "@perl `"%~dp0saisons`" %*"

Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Run it with:  saisons"
