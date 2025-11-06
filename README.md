# Cloudflare Workers AI - Invoice Extraction cURL Commands

This directory contains cURL commands to interact with Cloudflare Workers AI API for document extraction.

## Configuration

- **Account ID**: `9921006351e6d39ee4059dc50c134089`
- **API Key**: `wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1`
- **Model**: `@cf/google/gemma-3-12b-it` (adjust if your model identifier differs)

## Usage

### Option 1: Using the shell script

```bash
./cloudflare-ai-request.sh /path/to/your/file.pdf
# or
./cloudflare-ai-request.sh /path/to/your/image.jpg
```

### Option 2: Using the simple one-liner

```bash
./simple-curl.sh /path/to/your/file.pdf
```

### Option 3: Direct cURL command

Replace `<path-to-file>` with your actual file path:

```bash
curl -X POST \
  "https://api.cloudflare.com/client/v4/accounts/9921006351e6d39ee4059dc50c134089/ai/run/@cf/google/gemma-2-12b-it" \
  -H "Authorization: Bearer wSQMzqNtF011wplgjqakpQqLuKchph2tGFwQ_h_1" \
  -F "file=@<path-to-file>" \
  -F "system_prompt=<your-system-prompt>"
```

## Model Name

**Note**: The model name `@cf/google/gemma-2-12b-it` is an assumption based on your specification "gemma 12b it". If this doesn't work, you may need to:

1. Check your Cloudflare Workers AI dashboard for the exact model identifier
2. Common alternatives might be:
   - `@cf/google/gemma-2-12b-it`
   - `@cf/google/gemma-2b-it`
   - A custom model name specific to your account

## Response

The API will return JSON with the extracted invoice data according to the schema specified in the system prompt.

## Files

- `cloudflare-ai-request.sh` - Full-featured script with error handling
- `simple-curl.sh` - Minimal one-liner script
- `curl-command.txt` - Reference cURL command with full formatting

# ai-invoice
