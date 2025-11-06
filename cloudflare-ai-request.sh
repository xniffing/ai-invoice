#!/bin/bash

# Cloudflare Workers AI - Invoice Extraction Script
# This script sends a document (PDF/image) to Cloudflare Workers AI for invoice data extraction

set -e

# Configuration
ACCOUNT_ID="9921006351e6d39ee4059dc50c134089"
API_KEY="wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1"
MODEL="@cf/google/gemma-3-12b-it"
API_URL="https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/ai/run/${MODEL}"

# System prompt for structured invoice extraction
SYSTEM_PROMPT='Extract all invoice data from this document and return ONLY valid JSON matching this exact structure:

{
  "invoiceNumber": "string (from Invoice No., Número da Fatura, or header)",
  "invoiceDate": "YYYY-MM-DD (from Invoice Date, Data da Fatura)",
  "dueDate": "YYYY-MM-DD (from Due Date, Data de Vencimento)",

  "vendor": {
    "name": "string (top-left or header, from From, De, or logo area)",
    "address": "string (below vendor name or near Address, Morada)",
    "phone": "string (near address or Telefone)",
    "email": "string (near contact info, often bottom)",
    "vat": "string (near VAT, NIF, or Número de Identificação Fiscal)"
  },

  "customer": {
    "name": "string (near Bill To, Cliente, or Destinatário)",
    "address": "string (under customer name or labeled Address, Morada)",
    "phone": "string (optional)",
    "email": "string (optional)",
    "vat": "string (near VAT, NIF, Número de Contribuinte)"
  },

  "financials": {
    "shippingCost": 0.00,
    "subtotal": 0.00,
    "tax": 0.00,
    "taxRate": 0.00,
    "total": 0.00,
    "currency": "EUR"
  },

  "items": [
    {
      "description": "string",
      "quantity": 0,
      "unitPrice": 0.00,
      "totalPrice": 0.00,
      "taxRate": 0.00
    }
  ],

  "summary": {
    "itemCount": 0,
    "totalQuantity": 0
  },

  "metadata": {
    "processedAt": "ISO 8601 timestamp",
    "fileName": "extracted from input",
    "processor": "Cloudflare Workers AI"
  }
}

IMPORTANT:
- Return ONLY the JSON object, no additional text or explanation
- Use null for missing fields
- Ensure all numbers are numeric, not strings
- Date format must be YYYY-MM-DD
- Currency should be ISO 4217 code (EUR, USD, GBP, etc.)'

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

    # Try to extract and enrich the JSON response with actual metadata
    PROCESSED_RESPONSE=$(echo "$RESPONSE_BODY" | jq --arg file "$(basename "$FILE_PATH")" \
        --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        'if .result.response then
            .result.response |= (fromjson? // .) |
            if (.result.response | type) == "object" then
                .result.response.metadata.fileName = $file |
                .result.response.metadata.processedAt = $timestamp
            else . end
        else . end' 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$PROCESSED_RESPONSE" ]; then
        echo "Response:"
        echo "$PROCESSED_RESPONSE" | jq '.'
    else
        echo "Response:"
        echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    fi
    exit 0
else
    print_error "Request failed with HTTP status: $HTTP_CODE"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    exit 1
fi
