import 'package:flutter/material.dart';
import 'package:kiddolearn/screens/KindergartenGamesScreen.dart';
import 'package:kiddolearn/screens/KindergartenLearningScreen.dart';
import 'package:kiddolearn/screens/colour_guess_screen.dart';
import 'package:kiddolearn/screens/pronunciation_screen.dart';
import 'package:kiddolearn/screens/send_reset_code_screen.dart';

// Importing Screens
import 'screens/login_screen.dart';
import 'screens/learn_time_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/preschool_home_screen.dart';
import 'screens/kindergarten_home_screen.dart';
import 'screens/learn_shapes_screen.dart';
import 'screens/learn_colors_screen.dart';
import 'screens/learn_numbers_screen.dart';
import 'screens/learn_alphabets_screen.dart';
import 'screens/games_screen.dart';
import 'package:kiddolearn/screens/shapes_game_screen.dart';
import 'screens/nursery_rhymes_screen.dart';
import 'screens/learn_words_screen.dart';
import 'screens/clock_game.dart';
import 'screens/learn_numbers_2_screen.dart';
import 'screens/spell_it_game_screen.dart';
import 'screens/number_game.dart';
import 'screens/learning_screen.dart';

// NEW SCREEN
import 'screens/reset_password_screen.dart'; // NEW SCREEN
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KiddoLearn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        // Authentication Routes
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        RegistrationScreen.routeName: (ctx) => const RegistrationScreen(),
        '/send-reset-code': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          if (args is Map<String, dynamic> && args.containsKey('email')) {
            return SendResetCodeScreen(email: args['email']);
          }
          return SendResetCodeScreen(email: ""); // Default case
        },

        '/reset-password': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          if (args is Map<String, dynamic> && args.containsKey('email')) {
            return ResetPasswordScreen(email: args['email']);
          }
          return ResetPasswordScreen(email: ""); // Default if no email
        },
        // Preschool Routes
        PreschoolHomeScreen.routeName: (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          if (args is String) {
            return PreschoolHomeScreen(email: args);
          } else if (args is Map) {
            // If args is a map, extract the String key you need (e.g., 'email')
            String email = args['email'] ?? "";
            return PreschoolHomeScreen(email: email);
          } else {
            return PreschoolHomeScreen(email: "");
          }
        },
        '/learn_shapes': (ctx) => const LearnShapesScreen(),
        '/games_colour_guess': (ctx) => const ColorGame(),
        '/learn_numbers': (ctx) => const LearnNumbersScreen(),
        '/learn_alphabets': (ctx) => const LearnAlphabetsScreen(),
        '/games': (ctx) => const GamesScreen(),
        '/nursery_rhymes': (ctx) => const NurseryRhymesScreen(),
        '/learn': (ctx) => const LearningScreen(),

        // Kindergarten Routes
        KindergartenHomeScreen.routeName: (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments;
          if (args is String) {
            return KindergartenHomeScreen(email: args);
          } else if (args is Map) {
            // If it's a map, extract the string value you need (e.g., 'email')
            String email = args['email'] ?? "";
            return KindergartenHomeScreen(email: email);
          } else {
            return KindergartenHomeScreen(email: "");
          }
        },
        '/games_kindergarten': (ctx) => const KindergartenGamesScreen(),
        '/learn_words': (ctx) => const LearnWordsScreen(),
        '/time_game': (ctx) => LearnClock(),
        '/learn_numbers_2': (ctx) => LearnNumbers2Screen(),
        '/games_spell_it': (ctx) => const SpellItGameScreen(),
        '/learn_colors': (context) => const ColourLearnVideoScreen(),
        '/learning': (ctx) => const KindergartenLearningScreen(),
        '/pronunciation': (ctx) => PronunciationCheckScreen(),
        '/learn_time': (ctx) => LearnTimeScreen(),

        // Profile Route
        ProfileScreen.routeName: (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments as String?;
          return ProfileScreen(email: args ?? "");
        },

        // New Shapes Game Route (for the extra button)
        '/shapes_game': (ctx) => const ShapesGameScreen(),
        '/number_game': (ctx) => NumberMatchingGame(),
      },
    );
  }
}
