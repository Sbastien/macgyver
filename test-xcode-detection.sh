#!/bin/sh

# Test script to verify Xcode CLT detection methods

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Xcode Command Line Tools Detection Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Check if already installed
echo "1️⃣  Checking if Xcode CLT is already installed..."
if xcode-select -p >/dev/null 2>&1; then
    echo "   ✅ Already installed: $(xcode-select -p)"
else
    echo "   ❌ Not installed"
fi
echo ""

# Test 2: Check softwareupdate list
echo "2️⃣  Checking softwareupdate --list..."
echo "   (This may take 30-60 seconds...)"
OUTPUT=$(softwareupdate --list 2>&1)
echo "$OUTPUT" | head -20
echo ""

# Test 3: Try to find CLT package
echo "3️⃣  Attempting to find Command Line Tools package..."
PACKAGE=$(echo "$OUTPUT" | \
          grep -B 1 -E "Command Line Tools|Developer" | \
          awk -F"[*:]" '/^ *\*/ {print $2}' | \
          sed 's/^ *//;s/ *$//' | \
          grep -i "command" | \
          tail -n1)

if [ -n "$PACKAGE" ]; then
    echo "   ✅ Found: $PACKAGE"
else
    echo "   ❌ No package found in softwareupdate list"
    echo "   ℹ️  This is expected if CLT is already installed or not available via softwareupdate"
fi
echo ""

# Test 4: Alternative - check if can trigger xcode-select --install
echo "4️⃣  Checking xcode-select --install trigger..."
if xcode-select --install 2>&1 | grep -q "already installed"; then
    echo "   ✅ Already installed (via xcode-select)"
elif xcode-select --install 2>&1 | grep -q "install requested"; then
    echo "   ⚠️  Installation dialog triggered (you may need to close it)"
else
    echo "   ℹ️  Status unclear"
fi
echo ""

echo "5️⃣  Testing placeholder file method..."
echo "   Creating placeholder: /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress 2>/dev/null || echo "   ⚠️  Could not create placeholder"

echo "   Checking softwareupdate list after placeholder..."
OUTPUT2=$(softwareupdate --list 2>&1)
PACKAGE2=$(echo "$OUTPUT2" | grep "Command Line Tools" | head -n1)

if [ -n "$PACKAGE2" ]; then
    echo "   ✅ Placeholder triggered detection: $PACKAGE2"
else
    echo "   ❌ Still no package found"
fi

rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress 2>/dev/null
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "If no package found via softwareupdate:"
echo "  • Xcode CLT might already be installed"
echo "  • The placeholder trick might help detection"
echo "  • May need to use: sudo softwareupdate --install --all"
echo "  • Last resort: xcode-select --install (GUI)"
echo ""
