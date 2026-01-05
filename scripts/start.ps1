<#
.SYNOPSIS
    ShopEase Start Script
.DESCRIPTION
    Starts the Apache Tomcat server with ShopEase application.
.NOTES
    Run deploy.ps1 first to deploy the application.
#>

$ErrorActionPreference = "Stop"

$PROJECT_DIR = Split-Path -Parent $PSScriptRoot
if ($PROJECT_DIR -eq "") { $PROJECT_DIR = Get-Location }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ShopEase Start Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# Find Tomcat Home
# ============================================
function Find-TomcatHome {
    # Check saved location first
    $envFile = Join-Path "$PROJECT_DIR" "scripts\.tomcat_home"
    if (Test-Path "$envFile") {
        $savedPath = Get-Content "$envFile" -Raw
        $savedPath = $savedPath.Trim()
        if (Test-Path "$savedPath\bin\catalina.bat") {
            return $savedPath
        }
    }

    # Check environment variable
    if ($env:CATALINA_HOME -and (Test-Path "$env:CATALINA_HOME\bin\catalina.bat")) {
        return $env:CATALINA_HOME
    }

    # Search common Tomcat locations (dynamic version detection)
    $possiblePaths = @()

    # Search E:\tools for any Tomcat installation
    if (Test-Path "E:\tools") {
        Get-ChildItem "E:\tools" -Directory -Filter "apache-tomcat-*" -Recurse -Depth 1 -ErrorAction SilentlyContinue | ForEach-Object {
            $possiblePaths += $_.FullName
        }
    }

    # Search C:\DevTools for any Tomcat installation
    if (Test-Path "C:\DevTools") {
        Get-ChildItem "C:\DevTools" -Directory -Filter "apache-tomcat-*" -ErrorAction SilentlyContinue | ForEach-Object {
            $possiblePaths += $_.FullName
        }
    }

    $possiblePaths += @(
        "C:\DevTools\tomcat",
        "C:\Program Files\Apache Software Foundation\Tomcat 9.0",
        "D:\tomcat"
    )

    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path "$path\bin\catalina.bat")) {
            return $path
        }
    }

    return $null
}

$TOMCAT_HOME = Find-TomcatHome

if (-not $TOMCAT_HOME) {
    Write-Host "[ERROR] Tomcat not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run deploy.ps1 first, or set CATALINA_HOME environment variable." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Tomcat Home: $TOMCAT_HOME" -ForegroundColor Gray
Write-Host ""

# ============================================
# Check if already running
# ============================================
$port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue

if ($port8080) {
    Write-Host "[WARNING] Port 8080 is already in use!" -ForegroundColor Yellow
    Write-Host ""
    $processId = $port8080.OwningProcess
    $processName = (Get-Process -Id $processId).ProcessName
    Write-Host "Process: $processName (PID: $processId)" -ForegroundColor Gray
    Write-Host ""
    
    $response = Read-Host "Stop the existing process and restart? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        Write-Host "Stopping process..." -ForegroundColor Yellow
        Stop-Process -Id $processId -Force
        Start-Sleep -Seconds 2
        Write-Host "[OK] Process stopped" -ForegroundColor Green
    }
    else {
        Write-Host "Aborted." -ForegroundColor Gray
        exit 0
    }
}

# ============================================
# Verify WAR is deployed
# ============================================
$warPath = Join-Path "$TOMCAT_HOME" "webapps\shopease.war"
if (-not (Test-Path "$warPath")) {
    Write-Host "[ERROR] ShopEase WAR not found in Tomcat webapps!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please run deploy.ps1 first." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "[OK] WAR file found" -ForegroundColor Green

# ============================================
# Copy data directory if needed
# ============================================
$dataSource = Join-Path "$PROJECT_DIR" "data"
$dataTarget = Join-Path "$TOMCAT_HOME" "data"

if ((Test-Path "$dataSource") -and -not (Test-Path "$dataTarget")) {
    Copy-Item "$dataSource" "$dataTarget" -Recurse -Force
    Write-Host "[OK] Data directory copied" -ForegroundColor Green
}

# ============================================
# Start Tomcat
# ============================================
Write-Host ""
Write-Host "Starting Tomcat..." -ForegroundColor Yellow
Write-Host ""

$startupScript = Join-Path "$TOMCAT_HOME" "bin\startup.bat"

# Set environment for startup
$env:CATALINA_HOME = $TOMCAT_HOME

# Start Tomcat
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$startupScript`"" -WorkingDirectory "$TOMCAT_HOME\bin"

# Wait for startup
Write-Host "Waiting for server to start..." -ForegroundColor Gray
$maxWait = 30
$waited = 0

while ($waited -lt $maxWait) {
    Start-Sleep -Seconds 1
    $waited++
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/shopease" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            break
        }
    }
    catch { }
    
    Write-Host "." -NoNewline
}

Write-Host ""
Write-Host ""

# Check if started successfully
$port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue

if ($port8080) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Server Started Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Application URL:" -ForegroundColor White
    Write-Host "  http://localhost:8080/shopease" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Default accounts:" -ForegroundColor White
    Write-Host "  Customer: john_doe / pass123" -ForegroundColor Gray
    Write-Host "  Admin:    admin / admin123" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Use .\stop.ps1 to stop the server" -ForegroundColor Yellow
    Write-Host ""
    
    # Try to open browser
    Start-Process "http://localhost:8080/shopease"
}
else {
    Write-Host "[ERROR] Failed to start server" -ForegroundColor Red
    Write-Host ""
    Write-Host "Check Tomcat logs at:" -ForegroundColor Yellow
    Write-Host "  $TOMCAT_HOME\logs\catalina.out" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
