#!/bin/bash

# Simple invoice extraction script with base64 encoding
# Usage: ./simple-curl.sh <file-path>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file-path>"
    exit 1
fi

FILE_BASE64=$(base64 < "$1" | tr -d '\n')
PROMPT='Extract all invoice data and return ONLY valid JSON with this structure: {"invoiceNumber":"","invoiceDate":"YYYY-MM-DD","dueDate":"YYYY-MM-DD","vendor":{"name":"","address":"","phone":"","email":"","vat":""},"customer":{"name":"","address":"","phone":"","email":"","vat":""},"financials":{"shippingCost":0,"subtotal":0,"tax":0,"taxRate":0,"total":0,"currency":"EUR"},"items":[{"description":"","quantity":0,"unitPrice":0,"totalPrice":0,"taxRate":0}],"summary":{"itemCount":0,"totalQuantity":0},"metadata":{"processedAt":"","fileName":"","processor":"Cloudflare Workers AI"}}. Return ONLY JSON, no explanation. Use null for missing fields. Numbers must be numeric not strings.'

curl -X POST \
  "https://api.cloudflare.com/client/v4/accounts/9921006351e6d39ee4059dc50c134089/ai/run/@cf/google/gemma-3-12b-it" \
  -H "Authorization: Bearer wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg img "$FILE_BASE64" --arg prompt "$PROMPT" '{messages:[{role:"user",content:[{type:"image",source:{type:"base64",media_type:"image/jpeg",data:$img}},{type:"text",text:$prompt}]}]}')"
