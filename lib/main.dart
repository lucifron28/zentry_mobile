import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/project_provider.dart';
import 'providers/team_provider.dart';
import 'services/env_config.dart';
import 'services/webhook_service.dart';
import 'screens/main_layout.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  await EnvConfig.init();
  
  // Initialize webhook defaults
  await WebhookService.initializeDefaults();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ZentryApp());
}

class ZentryApp extends StatelessWidget {
  const ZentryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const AppInitializer(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0), // Prevent text scaling
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for providers to initialize
    await Future.wait([
      context.read<AuthProvider>().init(),
      context.read<ThemeProvider>().init(),
    ]);
    
    // Initialize other providers after a short delay to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        context.read<AchievementProvider>().init(),
        context.read<TeamProvider>().loadTeams(), // Load demo teams
        // Skip other providers for now since they don't have init() methods
        // context.read<TaskProvider>().init(),
        // context.read<ProjectProvider>().init(),
        // context.read<NotificationProvider>().init(),
      ]);
    });
    
    // Add a small delay for splash screen effect
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SplashScreen();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        if (authProvider.isAuthenticated) {
          return const MainLayout();
        }

        // For now, navigate directly to main layout
        // In a real app, you'd show auth screens here
        return const MainLayout();
      },
    );
  }
}
