# How to Get a Google Gemini API Key

## Step 1: Visit Google AI Studio
Go to [https://makersuite.google.com/app/apikey](https://makersuite.google.com/app/apikey)

## Step 2: Sign In
- Sign in with your Google account
- You don't need any special setup or credit card

## Step 3: Create API Key
- Click "Create API Key"
- Choose "Create API key in new project" (or select an existing project)
- Copy the generated API key

## Step 4: Configure Zentry Mobile
1. Open your project folder
2. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
3. Edit `.env` and replace the placeholder:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```
4. Restart the app completely (not hot reload)

## Step 5: Test (Optional)
You can test the API key using our test script:
```bash
dart test_gemini.dart your_api_key_here
```

## Free Tier Limits
- 15 requests per minute
- 1 million tokens per minute
- 1,500 requests per day

This is very generous for personal productivity apps!

## Troubleshooting
- **403 Forbidden**: Invalid API key
- **429 Rate Limited**: Too many requests, wait a minute
- **400 Bad Request**: Check the request format

## Security
- Never commit API keys to version control
- The `.env` file is already in `.gitignore`
- Keep your API key secure and don't share it publicly
