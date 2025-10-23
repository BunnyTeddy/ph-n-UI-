import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'providers/auth_provider.dart';

class PlantCareApp extends StatelessWidget {
  const PlantCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'Plant Care App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          
          // ========================================
          // 🎨 DEV MODE - Xem tất cả screens không cần Firebase
          // ========================================
          // Uncomment dòng này để vào Dev Mode:
          initialRoute: AppRoutes.dev,
          
          // Hoặc xem từng screen riêng:
          // AppRoutes.login         - Login screen
          // AppRoutes.register      - Register screen
          // AppRoutes.home          - Home screen
          // AppRoutes.addPlant      - Add plant screen
          // AppRoutes.settings      - Settings screen
          // AppRoutes.statistics    - Statistics screen
          
          // Production mode (sau khi có Firebase):
          // initialRoute: AppRoutes.home,
          
          // Original code (will restore after testing):
          // initialRoute: authProvider.isAuthenticated 
          //     ? AppRoutes.home 
          //     : AppRoutes.login,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}







