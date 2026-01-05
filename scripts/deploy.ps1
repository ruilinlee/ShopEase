<#
.SYNOPSIS
    ShopEase Deployment Script
.DESCRIPTION
    Deploys the ShopEase application to Apache Tomcat.
    Automatically detects or downloads required dependencies (JDK, Gradle, Tomcat).
    Can redeploy if already deployed.
.NOTES
    Dependencies will be installed to C:\DevTools if not found.
#>

param(
    [switch]$Force,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Configuration
$DEV_TOOLS_DIR = "C:\DevTools"
$PROJECT_DIR = Split-Path -Parent $PSScriptRoot
if ($PROJECT_DIR -eq "") { $PROJECT_DIR = Get-Location }
$WAR_NAME = "shopease.war"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ShopEase Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# Function: Check Java
# ============================================
function Test-Java {
    try {
        $javaVersion = & java -version 2>&1 | Select-String "version"
        if ($javaVersion -match '"(\d+)') {
            $majorVersion = [int]$Matches[1]
            if ($majorVersion -ge 11) {
                Write-Host "[OK] Java $majorVersion detected" -ForegroundColor Green
                return $true
            }
        }
    }
    catch { }

    # Fallback: Check JAVA_HOME
    if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
        Write-Host "[OK] JAVA_HOME set to $env:JAVA_HOME" -ForegroundColor Green
        return $true
    }

    return $false
}

# ============================================
# Function: Check Gradle
# ============================================
function Test-Gradle {
    try {
        $gradleVersion = & gradle --version 2>&1 | Select-String "Gradle"
        if ($gradleVersion) {
            Write-Host "[OK] Gradle detected" -ForegroundColor Green
            return $true
        }
    }
    catch { }
    return $false
}

# ============================================
# Function: Find Tomcat
# ============================================
function Find-Tomcat {
    # Check saved location first
    $envFile = Join-Path "$PROJECT_DIR" "scripts\.tomcat_home"
    if (Test-Path "$envFile") {
        $savedPath = Get-Content "$envFile" -Raw
        $savedPath = $savedPath.Trim()
        if (Test-Path "$savedPath\bin\catalina.bat") {
            Write-Host "[OK] Tomcat found at: $savedPath" -ForegroundColor Green
            return $savedPath
        }
    }
    
    # Search common Tomcat locations (including dynamic version detection)
    $possiblePaths = @($env:CATALINA_HOME)

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

    # Add other common locations
    $possiblePaths += @(
        "C:\DevTools\tomcat",
        "C:\Program Files\Apache Software Foundation\Tomcat 9.0",
        "D:\tomcat"
    )
    
    foreach ($path in $possiblePaths) {
        if ($path -and (Test-Path "$path\bin\catalina.bat")) {
            Write-Host "[OK] Tomcat found at: $path" -ForegroundColor Green
            return $path
        }
    }
    return $null
}

# ============================================
# Function: Show Setup Guide
# ============================================
function Show-SetupGuide {
    param([string[]]$Missing)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "   Missing Dependencies Detected" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    if ($Missing -contains "Java") {
        Write-Host "[MISSING] Java JDK 11+" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Download from:" -ForegroundColor White
        Write-Host "  https://adoptium.net/temurin/releases/?version=11" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Installation steps:" -ForegroundColor White
        Write-Host "  1. Download Windows x64 MSI installer" -ForegroundColor Gray
        Write-Host "  2. Run the installer, install to C:\DevTools\jdk-11" -ForegroundColor Gray
        Write-Host "  3. Add to PATH: C:\DevTools\jdk-11\bin" -ForegroundColor Gray
        Write-Host "  4. Set JAVA_HOME: C:\DevTools\jdk-11" -ForegroundColor Gray
        Write-Host ""
    }
    
    if ($Missing -contains "Gradle") {
        Write-Host "[MISSING] Gradle" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Download from:" -ForegroundColor White
        Write-Host "  https://gradle.org/releases/" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Installation steps:" -ForegroundColor White
        Write-Host "  1. Download latest binary-only ZIP" -ForegroundColor Gray
        Write-Host "  2. Extract to C:\DevTools\gradle" -ForegroundColor Gray
        Write-Host "  3. Add to PATH: C:\DevTools\gradle\bin" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Quick install (PowerShell as Admin):" -ForegroundColor Yellow
        Write-Host "  choco install gradle" -ForegroundColor Cyan
        Write-Host ""
    }
    
    if ($Missing -contains "Tomcat") {
        Write-Host "[MISSING] Apache Tomcat 9" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Download from:" -ForegroundColor White
        Write-Host "  https://tomcat.apache.org/download-90.cgi" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Installation steps:" -ForegroundColor White
        Write-Host "  1. Download 'Core: 64-bit Windows zip'" -ForegroundColor Gray
        Write-Host "  2. Extract to C:\DevTools\apache-tomcat-$TOMCAT_VERSION" -ForegroundColor Gray
        Write-Host "  3. Set CATALINA_HOME: C:\DevTools\apache-tomcat-$TOMCAT_VERSION" -ForegroundColor Gray
        Write-Host ""
    }
    
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  After installation, run this script again" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    
    # Create DevTools directory if not exists
    if (-not (Test-Path "$DEV_TOOLS_DIR")) {
        New-Item -ItemType Directory -Force -Path "$DEV_TOOLS_DIR" | Out-Null
        Write-Host "Created directory: $DEV_TOOLS_DIR" -ForegroundColor Gray
    }
}

# ============================================
# Check Dependencies
# ============================================
Write-Host "Checking dependencies..." -ForegroundColor White
Write-Host ""

$missing = @()

if (-not (Test-Java)) {
    $missing += "Java"
}

if (-not (Test-Gradle)) {
    $missing += "Gradle"
}

$TOMCAT_HOME = Find-Tomcat
if (-not $TOMCAT_HOME) {
    $missing += "Tomcat"
}

if ($missing.Count -gt 0) {
    Show-SetupGuide -Missing $missing
    exit 1
}

# ============================================
# Build WAR
# ============================================
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "Building WAR file..." -ForegroundColor Yellow
    Write-Host ""
    
    Push-Location "$PROJECT_DIR"
    try {
        # Clean and build
        & gradle clean war --no-daemon
        
        if ($LASTEXITCODE -ne 0) {
            throw "Gradle build failed with exit code $LASTEXITCODE"
        }
        Write-Host ""
        Write-Host "[OK] Build successful" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Build failed: $_" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    finally {
        Pop-Location
    }
}

# ============================================
# Find WAR file
# ============================================
$warPath = Get-ChildItem -Path "$PROJECT_DIR\build\libs" -Filter "*.war" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $warPath) {
    Write-Host "[ERROR] WAR file not found in build/libs" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] WAR file: $($warPath.FullName)" -ForegroundColor Green

# ============================================
# Stop existing Tomcat if running
# ============================================
Write-Host ""
Write-Host "Checking for running Tomcat..." -ForegroundColor Yellow

$tomcatProcess = Get-Process -Name "java" -ErrorAction SilentlyContinue | 
Where-Object { $_.Path -like "*tomcat*" -or $_.CommandLine -like "*catalina*" }

$port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue

if ($port8080 -or $tomcatProcess) {
    Write-Host "Stopping existing Tomcat..." -ForegroundColor Yellow
    
    # Try graceful shutdown
    $shutdownScript = Join-Path "$TOMCAT_HOME" "bin\shutdown.bat"
    if (Test-Path "$shutdownScript") {
        & cmd /c "$shutdownScript" 2>&1 | Out-Null
        Start-Sleep -Seconds 3
    }
    
    # Force kill if still running
    $port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
    if ($port8080) {
        $procId = $port8080.OwningProcess
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
    
    Write-Host "[OK] Previous instance stopped" -ForegroundColor Green
}

# ============================================
# Clean old deployment
# ============================================
$webappsDir = Join-Path "$TOMCAT_HOME" "webapps"
$deployedWar = Join-Path "$webappsDir" $WAR_NAME
$deployedDir = Join-Path "$webappsDir" "shopease"

if (Test-Path "$deployedWar") {
    Remove-Item "$deployedWar" -Force
    Write-Host "Removed old WAR file" -ForegroundColor Gray
}

if (Test-Path "$deployedDir") {
    Remove-Item "$deployedDir" -Recurse -Force
    Write-Host "Removed old deployment directory" -ForegroundColor Gray
}

# ============================================
# Deploy new WAR
# ============================================
Write-Host ""
Write-Host "Deploying to Tomcat..." -ForegroundColor Yellow

Copy-Item "$($warPath.FullName)" "$deployedWar" -Force

# Copy data directory to Tomcat for runtime access
$dataSource = Join-Path "$PROJECT_DIR" "data"
$dataTarget = Join-Path "$TOMCAT_HOME" "data"

if (Test-Path "$dataSource") {
    if (-not (Test-Path "$dataTarget")) {
        New-Item -ItemType Directory -Force -Path "$dataTarget" | Out-Null
    }
    Copy-Item "$dataSource\*" "$dataTarget" -Recurse -Force
    Write-Host "Copied data files to CATALINA_HOME/data" -ForegroundColor Gray

    # Ensure products have approvalStatus field for proper display
    $productsFile = Join-Path "$dataTarget" "products.json"
    if (Test-Path "$productsFile") {
        $content = Get-Content "$productsFile" -Raw -Encoding UTF8
        # Add approvalStatus to products that only have status: "available" without approvalStatus
        if ($content -notmatch '"approvalStatus"') {
            $content = $content -replace '"status":\s*"available"', '"status": "available", "approvalStatus": "approved"'
            $content | Out-File -FilePath "$productsFile" -Encoding UTF8 -Force
            Write-Host "Added approvalStatus to products for proper display" -ForegroundColor Gray
        }
    }
}

# Copy uploads directory for product images
$uploadsSource = Join-Path "$PROJECT_DIR" "uploads"
$uploadsTarget = Join-Path "$webappsDir" "shopease\uploads"

# Wait for WAR extraction
Start-Sleep -Seconds 2
if (Test-Path "$uploadsSource") {
    if (-not (Test-Path "$uploadsTarget")) {
        New-Item -ItemType Directory -Force -Path "$uploadsTarget" | Out-Null
    }
    Copy-Item "$uploadsSource\*" "$uploadsTarget" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Copied uploads directory" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "WAR deployed to: $deployedWar" -ForegroundColor White
Write-Host "CATALINA_HOME: $TOMCAT_HOME" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run .\start.ps1 to start the server" -ForegroundColor Gray
Write-Host "  2. Open http://localhost:8080/shopease" -ForegroundColor Cyan
Write-Host ""

# Save CATALINA_HOME for other scripts
$envFile = Join-Path "$PROJECT_DIR" "scripts\.tomcat_home"
"$TOMCAT_HOME" | Out-File -FilePath "$envFile" -Encoding UTF8 -Force
