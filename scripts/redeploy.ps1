<#
.SYNOPSIS
    ShopEase Complete Redeployment Script
.DESCRIPTION
    Performs a complete clean redeployment:
    1. Force stops all Java/Tomcat processes
    2. Cleans all build artifacts and Tomcat deployment
    3. Rebuilds the application from scratch
    4. Deploys and starts the server
    5. Verifies all pages are accessible
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ShopEase Complete Redeployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get Tomcat Home
$EnvFile = Join-Path $ScriptDir ".tomcat_home"
if (-not (Test-Path $EnvFile)) {
    Write-Host "[ERROR] Tomcat home not configured. Run deploy.ps1 first." -ForegroundColor Red
    exit 1
}
$TomcatHome = (Get-Content $EnvFile -Raw).Trim()

Write-Host "Project: $ProjectDir" -ForegroundColor Gray
Write-Host "Tomcat:  $TomcatHome" -ForegroundColor Gray
Write-Host ""

# ============================================
# Step 1: Force Stop ALL Java Processes
# ============================================
Write-Host "[1/5] Force Stopping Java Processes..." -ForegroundColor Yellow

# Try graceful shutdown first
$shutdownScript = Join-Path $TomcatHome "bin\shutdown.bat"
if (Test-Path $shutdownScript) {
    try { & cmd /c "$shutdownScript" 2>&1 | Out-Null } catch { }
    Start-Sleep -Seconds 2
}

# Force kill ALL java processes to ensure clean state
$javaProcesses = Get-Process -Name "java" -ErrorAction SilentlyContinue
if ($javaProcesses) {
    $javaProcesses | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        Write-Host "  Killed java process (PID: $($_.Id))" -ForegroundColor Gray
    }
    Start-Sleep -Seconds 2
}

# Verify port 8080 is free
$port8080 = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
if ($port8080) {
    $procId = $port8080.OwningProcess
    Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
    Write-Host "  Killed process holding port 8080 (PID: $procId)" -ForegroundColor Gray
    Start-Sleep -Seconds 2
}

Write-Host "  [OK] All Java processes stopped" -ForegroundColor Green

# ============================================
# Step 2: Clean Everything
# ============================================
Write-Host "[2/5] Cleaning All Artifacts..." -ForegroundColor Yellow

# Clean build directory
$BuildDir = Join-Path $ProjectDir "build"
if (Test-Path $BuildDir) {
    Remove-Item -Recurse -Force $BuildDir -ErrorAction SilentlyContinue
    Write-Host "  Removed build directory" -ForegroundColor Gray
}

# Clean Gradle cache
$GradleCacheDir = Join-Path $ProjectDir ".gradle"
if (Test-Path $GradleCacheDir) {
    Remove-Item -Recurse -Force $GradleCacheDir -ErrorAction SilentlyContinue
    Write-Host "  Removed .gradle cache" -ForegroundColor Gray
}

# Clean Tomcat webapps
$WebappsDir = Join-Path $TomcatHome "webapps"
$DeployedDir = Join-Path $WebappsDir "shopease"
$DeployedWar = Join-Path $WebappsDir "shopease.war"

if (Test-Path $DeployedDir) {
    Remove-Item -Recurse -Force $DeployedDir -ErrorAction SilentlyContinue
    Write-Host "  Removed webapps/shopease directory" -ForegroundColor Gray
}
if (Test-Path $DeployedWar) {
    Remove-Item -Force $DeployedWar -ErrorAction SilentlyContinue
    Write-Host "  Removed shopease.war" -ForegroundColor Gray
}

# Clean ENTIRE Tomcat work directory (critical for JSP recompilation)
$WorkCatalina = Join-Path $TomcatHome "work\Catalina"
if (Test-Path $WorkCatalina) {
    Remove-Item -Recurse -Force $WorkCatalina -ErrorAction SilentlyContinue
    Write-Host "  Cleared Tomcat work/Catalina directory (JSP cache)" -ForegroundColor Gray
}

# Clean Tomcat temp directory
$TempDir = Join-Path $TomcatHome "temp"
if (Test-Path $TempDir) {
    Get-ChildItem $TempDir -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "  Cleared Tomcat temp directory" -ForegroundColor Gray
}

Write-Host "  [OK] All artifacts cleaned" -ForegroundColor Green

# ============================================
# Step 3: Build from Scratch
# ============================================
Write-Host "[3/5] Building Application..." -ForegroundColor Yellow

Push-Location $ProjectDir
try {
    & gradle clean build --no-daemon 2>&1 | ForEach-Object {
        if ($_ -match "BUILD SUCCESSFUL") {
            Write-Host "  $_" -ForegroundColor Green
        } elseif ($_ -match "error|ERROR|FAILED") {
            Write-Host "  $_" -ForegroundColor Red
        }
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Gradle build failed"
    }
    Write-Host "  [OK] Build successful" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Build failed: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}
finally {
    Pop-Location
}

# ============================================
# Step 4: Deploy
# ============================================
Write-Host "[4/5] Deploying to Tomcat..." -ForegroundColor Yellow

# Find WAR file
$warPath = Get-ChildItem -Path "$ProjectDir\build\libs" -Filter "*.war" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $warPath) {
    Write-Host "[ERROR] WAR file not found" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $WebappsDir)) {
    New-Item -ItemType Directory -Force -Path $WebappsDir | Out-Null
    Write-Host "  Created webapps directory" -ForegroundColor Gray
}

# Copy WAR
Copy-Item $warPath.FullName $DeployedWar -Force
Write-Host "  Deployed WAR to webapps" -ForegroundColor Gray

# Copy data files to CATALINA_HOME/data
$dataSource = Join-Path $ProjectDir "data"
$dataTarget = Join-Path $TomcatHome "data"

if (Test-Path $dataSource) {
    if (-not (Test-Path $dataTarget)) {
        New-Item -ItemType Directory -Force -Path $dataTarget | Out-Null
    }
    Copy-Item "$dataSource\*" $dataTarget -Recurse -Force
    Write-Host "  Copied data files to CATALINA_HOME/data" -ForegroundColor Gray

    # Ensure products have approvalStatus field
    $productsFile = Join-Path $dataTarget "products.json"
    if (Test-Path $productsFile) {
        $content = Get-Content $productsFile -Raw -Encoding UTF8
        if ($content -notmatch '"approvalStatus"') {
            $content = $content -replace '"status":\s*"available"', '"status": "available", "approvalStatus": "approved"'
            $content | Out-File -FilePath $productsFile -Encoding UTF8 -Force
            Write-Host "  Added approvalStatus to products" -ForegroundColor Gray
        }
    }
}

Write-Host "  [OK] Deployment complete" -ForegroundColor Green

# ============================================
# Step 5: Start Server and Verify
# ============================================
Write-Host "[5/5] Starting Server and Verifying..." -ForegroundColor Yellow

# Start Tomcat
$startupScript = Join-Path $TomcatHome "bin\startup.bat"
$env:CATALINA_HOME = $TomcatHome
$env:CATALINA_BASE = $TomcatHome
try { & cmd /c "$startupScript" 2>&1 | Out-Null } catch { }

Write-Host "  Waiting for server to start..." -ForegroundColor Gray
$maxWait = 30
$waited = 0
while ($waited -lt $maxWait) {
    Start-Sleep -Seconds 2
    $waited += 2
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/shopease/" -UseBasicParsing -TimeoutSec 3 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "  Server is responding" -ForegroundColor Gray
            break
        }
    } catch {
        Write-Host "." -NoNewline -ForegroundColor Gray
    }
}
Write-Host ""

# Copy uploads after WAR is extracted
$uploadsSource = Join-Path $ProjectDir "uploads"
$uploadsTarget = Join-Path $DeployedDir "uploads"
if ((Test-Path $uploadsSource) -and (Test-Path $DeployedDir)) {
    Copy-Item "$uploadsSource\*" $uploadsTarget -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Copied uploads directory" -ForegroundColor Gray
}

# Verify key pages
Write-Host "  Verifying pages..." -ForegroundColor Gray
$testPages = @("index.jsp", "login.jsp", "shop.jsp", "admin_login.jsp")
$allPassed = $true

foreach ($page in $testPages) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/shopease/$page" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "    $page : OK" -ForegroundColor Green
        } else {
            Write-Host "    $page : $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "    $page : FAILED" -ForegroundColor Red
        $allPassed = $false
    }
}

# Check products display
try {
    $shopResponse = Invoke-WebRequest -Uri "http://localhost:8080/shopease/products" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    if ($shopResponse.Content -match "No products found") {
        Write-Host "    products : NO DATA (check products.json)" -ForegroundColor Yellow
    } else {
        Write-Host "    products : OK (displaying)" -ForegroundColor Green
    }
} catch {
    Write-Host "    products : FAILED" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Redeployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Application URL: http://localhost:8080/shopease" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test Accounts:" -ForegroundColor White
Write-Host "  Customer: john_doe / pass123" -ForegroundColor Gray
Write-Host "  Admin:    admin / admin123" -ForegroundColor Gray
Write-Host ""

if (-not $allPassed) {
    Write-Host "[WARNING] Some pages failed verification. Check Tomcat logs." -ForegroundColor Yellow
    Write-Host "Log file: $TomcatHome\logs\localhost.$(Get-Date -Format 'yyyy-MM-dd').log" -ForegroundColor Gray
}
