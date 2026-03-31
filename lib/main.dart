import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:tripsuite_app_boilerplate/features/auth/forgot_password_screen.dart';
import 'package:tripsuite_app_boilerplate/features/auth/login_screen.dart';
import 'package:tripsuite_app_boilerplate/features/auth/signup_screen.dart';
import 'package:tripsuite_app_boilerplate/features/expenses/providers/expense_tab_provider.dart';
import 'package:tripsuite_app_boilerplate/features/main/screens/main_shell_screen.dart';
import 'package:tripsuite_app_boilerplate/features/onboarding/screens/onboarding_screen_overview.dart';
import 'package:tripsuite_app_boilerplate/features/profile/providers/profile_image_provider.dart';
import 'package:tripsuite_app_boilerplate/features/trips/models/trips_manager.dart';
import 'package:tripsuite_app_boilerplate/features/wishlist/screens/wishlist_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseTabProvider()),
        ChangeNotifierProvider(create: (_) => WishlistManager()),
        ChangeNotifierProvider(create: (_) => TripsManager()),
        ChangeNotifierProvider(create: (_) => ProfileImageProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/main': (context) => const MainShellScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show main screen
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShellScreen();
        }

        // If user is not logged in, show onboarding
        return const OnboardingScreenOverview();
      },
    );
  }
}
