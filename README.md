# AI Invoice Extraction with Cloudflare Workers AI

Bash scripts for extracting structured invoice data from PDFs and images using Cloudflare Workers AI API. Supports multi-language invoices (English, Portuguese, etc.) with comprehensive structured output.

## Features

- ✅ **Structured JSON Output** - Detailed invoice data extraction following a standardized schema
- ✅ **Multi-language Support** - Handles English, Portuguese, and other language invoices
- ✅ **Base64 Encoding** - Proper file handling for the Cloudflare API
- ✅ **Error Handling** - Comprehensive validation and error reporting
- ✅ **Metadata Enrichment** - Automatic timestamp and filename injection

## Configuration

- **Account ID**: `9921006351e6d39ee4059dc50c134089`
- **API Key**: `wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1`
- **Model**: `@cf/google/gemma-3-12b-it`

## Quick Start

### 1. Test API Connection

```bash
./test-connection.sh
```

### 2. Extract Invoice Data

**Full-featured script with validation:**
```bash
./cloudflare-ai-request.sh "Amazon - INV-2022-32.pdf"
```

**Simple one-liner:**
```bash
./simple-curl.sh "Amazon - INV-2022-32.pdf"
```

**With custom prompt:**
```bash
./cloudflare-ai-request.sh invoice.pdf "Extract only vendor and total information"
```

## Structured Output Schema

All scripts extract invoice data in a comprehensive structured format:

```json
{
  "invoiceNumber": "INV-2022-32",
  "invoiceDate": "2022-03-15",
  "dueDate": "2022-04-15",

  "vendor": {
    "name": "Company Name",
    "address": "123 Street, City",
    "phone": "+1-555-0100",
    "email": "billing@company.com",
    "vat": "GB123456789"
  },

  "customer": {
    "name": "Customer Name",
    "address": "456 Avenue, Town",
    "phone": "+1-555-0200",
    "email": "customer@email.com",
    "vat": "GB987654321"
  },

  "financials": {
    "shippingCost": 15.00,
    "subtotal": 500.00,
    "tax": 100.00,
    "taxRate": 20.00,
    "total": 615.00,
    "currency": "EUR"
  },

  "items": [
    {
      "description": "Product Name",
      "quantity": 2,
      "unitPrice": 250.00,
      "totalPrice": 500.00,
      "taxRate": 20.00
    }
  ],

  "summary": {
    "itemCount": 1,
    "totalQuantity": 2
  },

  "metadata": {
    "processedAt": "2024-01-15T10:30:00Z",
    "fileName": "invoice.pdf",
    "processor": "Cloudflare Workers AI"
  }
}
```

### Supported Languages

The schema supports multi-language invoice extraction:
- **English**: Invoice No., Due Date, Bill To, Tax
- **Portuguese**: Número da Fatura, Data de Vencimento, Cliente, IVA
- **Other languages**: Automatically detected and extracted

### Field Descriptions

See `invoice-schema.json` for the complete JSON Schema definition with detailed field descriptions and validation rules.

## Project Files

| File | Description |
|------|-------------|
| `cloudflare-ai-request.sh` | Full-featured script with validation, error handling, colored output |
| `simple-curl.sh` | Minimal one-liner script for quick testing |
| `test-connection.sh` | API connection and authentication test utility |
| `curl-command.txt` | Reference cURL commands with base64 encoding examples |
| `invoice-schema.json` | JSON Schema definition for structured output |
| `examples/` | Directory for test invoice files |
| `Amazon - INV-2022-32.pdf` | Sample invoice for testing |

## Technical Details

### Base64 Encoding

The Cloudflare Workers AI API requires files to be sent as base64-encoded data in JSON format:

```bash
# Convert file to base64 (remove newlines)
FILE_BASE64=$(base64 < invoice.pdf | tr -d '\n')

# Send in JSON payload
curl -X POST "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg img "$FILE_BASE64" ...)"
```

### Response Format

The AI returns responses wrapped in Cloudflare's API structure:

```json
{
  "result": {
    "response": "{ invoice JSON here }"
  },
  "success": true
}
```

The `cloudflare-ai-request.sh` script automatically extracts and enriches the invoice data with actual metadata.

## Troubleshooting

### 403 Access Denied

- Verify your API key is valid and not expired
- Check that the account ID matches your Cloudflare account
- Ensure Workers AI is enabled on your account
- Confirm you have access to the Gemma model

### Empty or Invalid Response

- Check that the file is a valid PDF or image (JPEG, PNG)
- Ensure the file contains visible invoice text
- Try with a different invoice to verify the format

### jq Command Not Found

Install jq for JSON processing:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

## License

MIT
