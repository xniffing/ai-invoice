#!/bin/bash

# Simple one-liner invoice extraction script
# Usage: ./simple-curl.sh <file-path>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file-path>"
    exit 1
fi

curl -X POST \
  "https://api.cloudflare.com/client/v4/accounts/9921006351e6d39ee4059dc50c134089/ai/run/@cf/google/gemma-3-12b-it" \
  -H "Authorization: Bearer wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1" \
  -F "file=@$1" \
  -F "system_prompt=Extract invoice data from this document. Return JSON with: invoice_number, date, vendor_name, total_amount, line_items, tax_amount, currency."
