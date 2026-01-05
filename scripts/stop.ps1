<#
.SYNOPSIS
    ShopEase Stop Script
.DESCRIPTION
    Stops all ShopEase services and releases ports.
.NOTES
    Stops Tomcat and any processes using port 8080.
#>

$ErrorActionPreference = "SilentlyContinue"

$PROJECT_DIR = Split-Path -Parent $PSScriptRoot
if ($PROJECT_DIR -eq "") { $PROJECT_DIR = Get-Location }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ShopEase Stop Script" -ForegroundColor Cyan
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

# ============================================
# Try graceful Tomcat shutdown
# ============================================
if ($TOMCAT_HOME) {
    Write-Host "Tomcat Home: $TOMCAT_HOME" -ForegroundColor Gray
    Write-Host ""
    
    $shutdownScript = Join-Path "$TOMCAT_HOME" "bin\shutdown.bat"
    
    if (Test-Path "$shutdownScript") {
        Write-Host "Sending shutdown signal to Tomcat..." -ForegroundColor Yellow
        
        $env:CATALINA_HOME = $TOMCAT_HOME
        & cmd /c "$shutdownScript" 2>&1 | Out-Null
        
        # Wait for graceful shutdown
        Start-Sleep -Seconds 3
    }
}

# ============================================
# Check and kill port 8080
# ============================================
Write-Host "Checking port 8080..." -ForegroundColor Yellow

$port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue

if ($port8080) {
    $processId = $port8080.OwningProcess
    $process = Get-Process -Id $processId -ErrorAction SilentlyContinue
    
    if ($process) {
        Write-Host "Found process: $($process.ProcessName) (PID: $processId)" -ForegroundColor Gray
        Write-Host "Stopping process..." -ForegroundColor Yellow
        
        Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        # Verify
        $port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
        if (-not $port8080) {
            Write-Host "[OK] Process stopped" -ForegroundColor Green
        }
        else {
            Write-Host "[WARNING] Process may still be running" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "Port 8080 is not in use" -ForegroundColor Gray
}

# ============================================
# Also check port 8005 (Tomcat shutdown port)
# ============================================
$port8005 = Get-NetTCPConnection -LocalPort 8005 -State Listen -ErrorAction SilentlyContinue
if ($port8005) {
    $processId = $port8005.OwningProcess
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped shutdown port listener (8005)" -ForegroundColor Gray
}

# ============================================
# Check port 8009 (AJP connector)
# ============================================
$port8009 = Get-NetTCPConnection -LocalPort 8009 -State Listen -ErrorAction SilentlyContinue
if ($port8009) {
    $processId = $port8009.OwningProcess
    Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
    Write-Host "Stopped AJP connector (8009)" -ForegroundColor Gray
}

# ============================================
# Kill any remaining java processes related to Tomcat
# ============================================
$javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue | 
Where-Object { 
    try {
        $_.Path -like "*tomcat*" -or 
        $_.MainWindowTitle -like "*Tomcat*"
    }
    catch { $false }
}

foreach ($proc in $javaProcesses) {
    Write-Host "Stopping Tomcat Java process (PID: $($proc.Id))..." -ForegroundColor Yellow
    Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
}

# ============================================
# Final verification
# ============================================
Write-Host ""
Start-Sleep -Seconds 1

$port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue

if (-not $port8080) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   All Services Stopped" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Port 8080 is now available" -ForegroundColor White
    Write-Host ""
    Write-Host "Use .\start.ps1 to restart the server" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "   Warning: Port 8080 Still In Use" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    $processId = $port8080.OwningProcess
    Write-Host "Process ID: $processId" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Try running as Administrator:" -ForegroundColor Yellow
    Write-Host "  Stop-Process -Id $processId -Force" -ForegroundColor Cyan
    Write-Host ""
}
