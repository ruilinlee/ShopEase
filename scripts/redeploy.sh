#!/bin/bash
#
# ShopEase Complete Redeployment Script for macOS
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TOMCAT_HOME="/opt/homebrew/opt/tomcat@9/libexec"

echo ""
echo "========================================"
echo "   ShopEase Complete Redeployment"
echo "========================================"
echo ""
echo "Project: $PROJECT_DIR"
echo "Tomcat:  $TOMCAT_HOME"
echo ""

# ============================================
# Step 1: Stop Java/Tomcat Processes
# ============================================
echo "[1/5] Stopping Java Processes..."

# Stop Tomcat gracefully
if [ -f "$TOMCAT_HOME/bin/shutdown.sh" ]; then
    "$TOMCAT_HOME/bin/shutdown.sh" 2>/dev/null || true
    sleep 2
fi

# Kill any process on port 8080
if lsof -ti:8080 >/dev/null 2>&1; then
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
    echo "  Killed processes on port 8080"
    sleep 2
fi

echo "  [OK] All Java processes stopped"

# ============================================
# Step 2: Clean Everything
# ============================================
echo "[2/5] Cleaning All Artifacts..."

# Clean build directory
if [ -d "$PROJECT_DIR/build" ]; then
    rm -rf "$PROJECT_DIR/build"
    echo "  Removed build directory"
fi

# Clean Gradle cache
if [ -d "$PROJECT_DIR/.gradle" ]; then
    rm -rf "$PROJECT_DIR/.gradle"
    echo "  Removed .gradle cache"
fi

# Clean Tomcat webapps
rm -rf "$TOMCAT_HOME/webapps/shopease" 2>/dev/null || true
rm -f "$TOMCAT_HOME/webapps/shopease.war" 2>/dev/null || true
echo "  Removed shopease from webapps"

# Clean Tomcat work directory
rm -rf "$TOMCAT_HOME/work/Catalina" 2>/dev/null || true
echo "  Cleared Tomcat work directory"

# Clean Tomcat temp
rm -rf "$TOMCAT_HOME/temp/"* 2>/dev/null || true
echo "  Cleared Tomcat temp directory"

echo "  [OK] All artifacts cleaned"

# ============================================
# Step 3: Build from Scratch
# ============================================
echo "[3/5] Building Application..."

cd "$PROJECT_DIR"

if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    ./gradlew clean build --no-daemon
else
    gradle clean build --no-daemon
fi

if [ $? -ne 0 ]; then
    echo "[ERROR] Build failed!"
    exit 1
fi

echo "  [OK] Build successful"

# ============================================
# Step 4: Deploy
# ============================================
echo "[4/5] Deploying to Tomcat..."

# Find WAR file
WAR_FILE=$(find "$PROJECT_DIR/build/libs" -name "*.war" | head -1)
if [ -z "$WAR_FILE" ]; then
    echo "[ERROR] WAR file not found!"
    exit 1
fi

# Copy WAR
cp "$WAR_FILE" "$TOMCAT_HOME/webapps/shopease.war"
echo "  Deployed WAR to webapps"

# Copy data files
if [ -d "$PROJECT_DIR/data" ]; then
    mkdir -p "$TOMCAT_HOME/data"
    cp -r "$PROJECT_DIR/data/"* "$TOMCAT_HOME/data/"
    echo "  Copied data files to CATALINA_HOME/data"
fi

echo "  [OK] Deployment complete"

# ============================================
# Step 5: Start Server and Verify
# ============================================
echo "[5/5] Starting Server and Verifying..."

# Start Tomcat
export CATALINA_HOME="$TOMCAT_HOME"
export CATALINA_BASE="$TOMCAT_HOME"
"$TOMCAT_HOME/bin/startup.sh"

echo "  Waiting for server to start..."
MAX_WAIT=30
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    sleep 2
    WAITED=$((WAITED + 2))
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/shopease/" 2>/dev/null | grep -q "200"; then
        echo "  Server is responding"
        break
    fi
    echo -n "."
done
echo ""

# Wait for WAR extraction
sleep 3

# Copy uploads after WAR is extracted
if [ -d "$PROJECT_DIR/uploads" ] && [ -d "$TOMCAT_HOME/webapps/shopease" ]; then
    cp -r "$PROJECT_DIR/uploads/"* "$TOMCAT_HOME/webapps/shopease/uploads/" 2>/dev/null || true
    echo "  Copied uploads directory"
fi

# Verify key pages
echo "  Verifying pages..."
PAGES=("index.jsp" "login.jsp" "shop.jsp" "admin_login.jsp")
ALL_PASSED=true

for PAGE in "${PAGES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080/shopease/$PAGE" 2>/dev/null)
    if [ "$STATUS" = "200" ]; then
        echo "    $PAGE : OK"
    else
        echo "    $PAGE : FAILED ($STATUS)"
        ALL_PASSED=false
    fi
done

echo ""
echo "========================================"
echo "   Redeployment Complete!"
echo "========================================"
echo ""
echo "Application URL: http://localhost:8080/shopease"
echo ""
echo "Test Accounts:"
echo "  Customer: john_doe / pass123"
echo "  Admin:    admin / admin123"
echo ""

if [ "$ALL_PASSED" = false ]; then
    echo "[WARNING] Some pages failed verification. Check Tomcat logs."
    echo "Log file: $TOMCAT_HOME/logs/catalina.out"
fi
