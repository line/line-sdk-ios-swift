#!/bin/bash
# Extract screenshots from xcresult bundle

set -eo pipefail

XCRESULT_PATH="${1:-TestResults.xcresult}"
SCREENSHOTS_DIR="${2:-screenshots}"

if [ ! -d "$XCRESULT_PATH" ]; then
    echo "Error: xcresult bundle not found at $XCRESULT_PATH"
    exit 1
fi

echo "🔍 Extracting screenshots from $XCRESULT_PATH..."

# Create screenshots directory
mkdir -p "$SCREENSHOTS_DIR"

# Extract test report ID
TEST_REPORT_ID=$(xcrun xcresulttool get --path "$XCRESULT_PATH" --format json | \
    jq -r '.actions._values[] | select(.actionResult.testsRef) | .actionResult.testsRef.id._value' | head -1)

if [ -z "$TEST_REPORT_ID" ]; then
    echo "⚠️  No test report found in xcresult bundle"
    exit 0
fi

echo "📋 Found test report: $TEST_REPORT_ID"

# Function to extract attachments from a test
extract_attachments() {
    local test_id="$1"
    local test_name="$2"
    
    # Get test details
    xcrun xcresulttool get --path "$XCRESULT_PATH" --id "$test_id" --format json | \
    jq -r '.summaryRef.attachments._values[]? | select(.uniformTypeIdentifier._value == "public.png") | .payloadRef.id._value' | \
    while read -r attachment_id; do
        if [ ! -z "$attachment_id" ]; then
            # Clean test name for filename
            clean_name=$(echo "$test_name" | sed 's/[^a-zA-Z0-9_-]/_/g')
            filename="${clean_name}_${attachment_id:0:8}.png"
            
            echo "  📸 Extracting: $filename"
            xcrun xcresulttool get --path "$XCRESULT_PATH" --id "$attachment_id" > "$SCREENSHOTS_DIR/$filename"
        fi
    done
}

# Get all test results
echo "🔎 Searching for failed tests with screenshots..."

xcrun xcresulttool get --path "$XCRESULT_PATH" --id "$TEST_REPORT_ID" --format json | \
jq -r '
    .. |
    objects |
    select(.testStatus? and .testStatus._value == "Failure") |
    {id: .summaryRef.id._value, name: .name._value}
' | jq -s '.' | jq -r '.[] | "\(.id)|\(.name)"' | \
while IFS='|' read -r test_id test_name; do
    if [ ! -z "$test_id" ]; then
        echo "❌ Failed test: $test_name"
        extract_attachments "$test_id" "$test_name"
    fi
done

# Count screenshots
SCREENSHOT_COUNT=$(find "$SCREENSHOTS_DIR" -name "*.png" 2>/dev/null | wc -l | tr -d ' ')

if [ "$SCREENSHOT_COUNT" -eq 0 ]; then
    echo "✅ No screenshots found (all tests passed or no screenshots were captured)"
else
    echo "📊 Extracted $SCREENSHOT_COUNT screenshot(s) to $SCREENSHOTS_DIR"
fi