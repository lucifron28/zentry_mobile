# Zentry Mobile

A gamified productivity app built with Flutter, featuring AI-powered assistance through Zenturion.

## Features

- 📱 **Task Management** - Create, organize, and track your tasks
- 📁 **Project Organization** - Group tasks into projects with progress tracking
- 🏆 **Achievement System** - Earn XP and unlock achievements
- 🤖 **AI Assistant (Zenturion)** - Get productivity help powered by OpenAI
- 📊 **Progress Dashboard** - Visual overview of your productivity

## Getting Started

### Prerequisites
- Flutter SDK (>=3.8.1)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd zentry_mobile
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## AI Assistant Setup (Zenturion)

To enable the full AI capabilities of Zenturion:

### 1. Get OpenAI API Key
- Visit [OpenAI Platform](https://platform.openai.com/api-keys)
- Create an account or sign in
- Generate a new API key
- Ensure you have credits in your account

### 2. Configure Environment Variables
- Copy `.env.example` to `.env` in the project root:
```bash
cp .env.example .env
```

- Open `.env` and replace the placeholder with your actual API key:
```env
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
```

### 3. Optional Configuration
You can customize other settings in `.env`:
```env
OPENAI_MODEL=gpt-3.5-turbo          # AI model to use
OPENAI_MAX_TOKENS=500               # Response length limit
OPENAI_TEMPERATURE=0.7              # Creativity level (0-2)
DEBUG_MODE=true                     # Enable debug features
```

### 4. Test the Integration
- Restart the app to load the new configuration
- Navigate to the AI Assistant tab (middle tab with brain icon)
- Start a conversation with Zenturion
- The info button shows configuration status

### Cost Information
- Model: GPT-3.5-turbo (fast and cost-effective)
- Estimated cost: ~$0.001-0.005 per conversation
- Input: $0.0015 per 1K tokens
- Output: $0.002 per 1K tokens

### Demo Mode
If the `.env` file is missing or the API key isn't configured, Zenturion runs in demo mode with smart placeholder responses.

### Security Note
- **Never commit your `.env` file with real API keys to version control!**
- The `.env` file is already added to `.gitignore`
- Use `.env.example` for documentation and sharing

## Project Structure

```
lib/
├── models/          # Data models (Task, Project, Achievement, User)
├── providers/       # State management with Provider
├── screens/         # UI screens
├── services/        # API services (AI, authentication, etc.)
├── utils/          # Constants, themes, utilities
└── widgets/        # Reusable UI components
```

## Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **OpenAI GPT-3.5-turbo** - AI assistant capabilities
- **HTTP** - API communication
- **Shared Preferences** - Local data persistence
- **Glassmorphism** - Modern UI effects

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
