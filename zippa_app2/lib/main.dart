import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zippa_app/core/api_client.dart';
import 'package:zippa_app/providers/auth_provider.dart';
import 'package:zippa_app/providers/job_provider.dart';
import 'package:zippa_app/providers/rider_provider.dart';
import 'package:zippa_app/screens/shared/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  runApp(const ZippaApp());
}

class ZippaApp extends StatelessWidget {
  const ZippaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => RiderProvider()),
      ],
      child: MaterialApp(
        title        : 'Zippa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme     : ColorScheme.fromSeed(
            seedColor     : const Color(0xFF1A1A2E),
            primary       : const Color(0xFF1A1A2E),
            secondary     : const Color(0xFFE94560),
          ),
          useMaterial3    : true,
          fontFamily      : 'Helvetica',
          appBarTheme     : const AppBarTheme(
            backgroundColor : Color(0xFF1A1A2E),
            foregroundColor : Colors.white,
            elevation       : 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor : const Color(0xFFE94560),
              foregroundColor : Colors.white,
              minimumSize     : const Size(double.infinity, 52),
              shape           : RoundedRectangleBorder(
                borderRadius  : BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}