#!/bin/bash

# Cloudflare Workers AI - Invoice Extraction Script
# This script sends a document (PDF/image) to Cloudflare Workers AI for invoice data extraction

set -e

# Configuration
ACCOUNT_ID="9921006351e6d39ee4059dc50c134089"
API_KEY="wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1"
MODEL="@cf/google/gemma-3-12b-it"
API_URL="https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/ai/run/${MODEL}"

# System prompt for invoice extraction
SYSTEM_PROMPT="Extract invoice data from this document. Return a JSON with the following fields: invoice_number, date, vendor_name, total_amount, line_items (array of {description, quantity, unit_price, total}), tax_amount, and currency."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

# Check if file argument is provided
if [ $# -eq 0 ]; then
    print_error "No file specified"
    echo "Usage: $0 <path-to-file> [custom-system-prompt]"
    echo ""
    echo "Examples:"
    echo "  $0 invoice.pdf"
    echo "  $0 receipt.jpg \"Extract receipt data\""
    exit 1
fi

FILE_PATH="$1"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    print_error "File not found: $FILE_PATH"
    exit 1
fi

# Use custom system prompt if provided
if [ $# -ge 2 ]; then
    SYSTEM_PROMPT="$2"
fi

# Check file type
FILE_TYPE=$(file --mime-type -b "$FILE_PATH")
print_info "File type detected: $FILE_TYPE"

# Validate file type
case "$FILE_TYPE" in
    application/pdf|image/jpeg|image/png|image/jpg)
        print_info "File type supported"
        ;;
    *)
        print_error "Unsupported file type: $FILE_TYPE"
        echo "Supported types: PDF, JPEG, PNG"
        exit 1
        ;;
esac

# Get file size
FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null)
print_info "File size: $(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "$FILE_SIZE bytes")"

# Convert file to base64
print_info "Converting file to base64..."
FILE_BASE64=$(base64 < "$FILE_PATH" | tr -d '\n')
BASE64_SIZE=${#FILE_BASE64}
print_info "Base64 encoded size: $BASE64_SIZE characters"

# Print request details
echo ""
print_info "Sending request to Cloudflare Workers AI..."
echo "  Model: $MODEL"
echo "  File: $FILE_PATH"
echo ""

# Create JSON payload
JSON_PAYLOAD=$(jq -n \
  --arg image "$FILE_BASE64" \
  --arg prompt "$SYSTEM_PROMPT" \
  '{
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "image",
            "source": {
              "type": "base64",
              "media_type": "image/jpeg",
              "data": $image
            }
          },
          {
            "type": "text",
            "text": $prompt
          }
        ]
      }
    ]
  }')

# Make the API request
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")

# Extract HTTP status code (last line)
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

# Check HTTP status
if [ "$HTTP_CODE" -eq 200 ]; then
    print_success "Request completed successfully"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    exit 0
else
    print_error "Request failed with HTTP status: $HTTP_CODE"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY"
    exit 1
fi
