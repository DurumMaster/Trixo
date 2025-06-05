import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:trixo_frontend/features/auth/presentation/providers/providers.dart';
import 'firebase_options.dart';

import 'package:trixo_frontend/config/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  Stripe.publishableKey = "pk_test_51RVWvGQtk4e56mvxFmPID1af9cXYGp5M4o53pGlAAlfHGXzVvBFL052Zi9dsMAbqWJQAPEWWau5PnM7fQ1QFp3bg00SmHwH4YL";
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Trixo',
      routerConfig: appRouter,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
