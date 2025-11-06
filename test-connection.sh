#!/bin/bash

# Test script to verify Cloudflare API connection
# This doesn't send a file, just tests the API endpoint

set -e

ACCOUNT_ID="9921006351e6d39ee4059dc50c134089"
API_KEY="wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1"

echo "Testing Cloudflare API connection..."
echo ""

# Test basic API access
RESPONSE=$(curl -s -w "\n%{http_code}" \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/ai/models" \
  -H "Authorization: Bearer $API_KEY")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✓ Connection successful!"
    echo ""
    echo "Available models:"
    echo "$RESPONSE_BODY" | jq -r '.result[] | select(.name | contains("gemma")) | .name' 2>/dev/null || echo "$RESPONSE_BODY"
else
    echo "✗ Connection failed with HTTP status: $HTTP_CODE"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY"
    exit 1
fi
