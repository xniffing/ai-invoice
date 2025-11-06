# Example Files

Place your test invoice PDFs or images in this directory.

## Supported Formats

- PDF files (`.pdf`)
- JPEG images (`.jpg`, `.jpeg`)
- PNG images (`.png`)

## Usage

Once you have sample files here, you can test the scripts:

```bash
# Using the full-featured script
../cloudflare-ai-request.sh ./your-invoice.pdf

# Using the simple script
../simple-curl.sh ./your-receipt.jpg
```

## Sample Invoice Data

For testing, you can use any invoice or receipt image/PDF. The AI will attempt to extract:

- Invoice number
- Date
- Vendor name
- Total amount
- Line items (description, quantity, unit price, total)
- Tax amount
- Currency
