#!/bin/bash

# Test script to verify Cloudflare API connection and credentials

ACCOUNT_ID="9921006351e6d39ee4059dc50c134089"
API_KEY="wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1"
MODEL="@cf/google/gemma-2-12b-it"

echo "Testing Cloudflare Workers AI API..."
echo "Account: ${ACCOUNT_ID}"
echo "Model: ${MODEL}"
echo ""

# Test with a simple text prompt (no file required)
echo "Sending test request..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/ai/run/${MODEL}" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"Say hello in JSON format: {\"message\": \"...\"}","max_tokens":50}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

echo ""
if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✓ API connection successful!"
    echo "✓ Authentication valid"
    echo "✓ Model is accessible"
    echo ""
    echo "Test response:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    echo ""
    echo "You're all set! Use the invoice extraction scripts with your PDF/image files."
    exit 0
else
    echo "✗ Connection failed with HTTP status: $HTTP_CODE"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    echo ""
    echo "Possible issues:"
    echo "  - Check your API key is valid"
    echo "  - Verify the account ID is correct"
    echo "  - Ensure the model name is available in your account"
    exit 1
fi
