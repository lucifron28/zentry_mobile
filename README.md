# Zentry Mobile

A gamified productivity app built with Flutter, featuring AI-powered assistance through Zenturion.

## Features

- 📱 **Task Management** - Create, organize, and track your tasks
- 📁 **Project Organization** - Group tasks into projects with progress tracking
- 🏆 **Achievement System** - Earn XP and unlock achievements
- 🤖 **AI Assistant (Zenturion)** - Get productivity help powered by Google Gemini
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

### 1. Get Google Gemini API Key
- Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
- Create an account or sign in with your Google account
- Generate a new API key
- The free tier offers generous limits for personal use

### 2. Configure Environment Variables
- Copy `.env.example` to `.env` in the project root:
```bash
cp .env.example .env
```

- Open `.env` and replace the placeholder with your actual API key:
```env
GEMINI_API_KEY=your-actual-gemini-api-key-here
```

### 3. Optional Configuration
You can customize other settings in `.env`:
```env
GEMINI_MODEL=gemini-1.5-flash       # AI model to use (fast and efficient)
GEMINI_MAX_TOKENS=2048              # Response length limit
GEMINI_TEMPERATURE=0.7              # Creativity level (0-2)
DEBUG_MODE=true                     # Enable debug features
```

### 4. Test the Integration
- Restart the app to load the new configuration
- Navigate to the AI Assistant tab (middle tab with brain icon)
- Start a conversation with Zenturion
- The debug info shows configuration status

### Advantages of Gemini
- **Free tier** with generous limits
- **Fast responses** and better context understanding
- **Multimodal capabilities** (text, images)
- **Higher quality** responses compared to older models
- **No credit card required** for basic usage

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
- **Google Gemini** - AI assistant capabilities
- **HTTP** - API communication
- **Shared Preferences** - Local data persistence
- **Glassmorphism** - Modern UI effects

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
