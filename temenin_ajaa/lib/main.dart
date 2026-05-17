// Path: lib\main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:temenin_ajaa/modules/auth/onboarding/screens/onboarding_screen.dart';
import 'package:temenin_ajaa/modules/clients/screens/home_loggedin_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://qwtowvjzokxafcnzcurm.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3dG93dmp6b2t4YWZjbnpjdXJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0ODYzOTAsImV4cCI6MjA5NDA2MjM5MH0.XYM2Hxc-vcu7Gr35OAbEZRdxzgR67Hvm7J75ZFTEz7A',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Supabase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        title: 'Temenin Ajaa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Poppins',
          scaffoldBackgroundColor: const Color(0xFF0B0910),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF9DCC),
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
          ),
        ),
        home: const AuthWrapper(),
        onGenerateRoute: (settings) {
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasCheckedAuth = false;
  bool _hasRefreshedOnce = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration.zero);
    if (mounted && !_hasCheckedAuth) {
      _hasCheckedAuth = true;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();
      
      // Refresh user data only once after successful auth
      if (mounted && authProvider.isAuthenticated && authProvider.user != null && !_hasRefreshedOnce) {
        _hasRefreshedOnce = true;
        await authProvider.refreshUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    /// LOADING STATE
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9DCC)),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Memuat...',
                style: TextStyle(
                  color: Color(0xFFFF9DCC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// CHECK IF ERROR OCCURRED
    if (authProvider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Terjadi Kesalahan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _hasCheckedAuth = false;
                    _hasRefreshedOnce = false;
                    authProvider.checkAuthStatus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9DCC),
                    foregroundColor: const Color(0xFF6F004B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// LOGIN SUCCESS - USER AUTHENTICATED
    if (authProvider.isAuthenticated && authProvider.user != null) {
      return const HomeLoggedInScreen();
    }

    /// NOT LOGGED IN - SHOW ONBOARDING
    return const OnboardingScreen();
  }
}