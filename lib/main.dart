import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/controllers/auth_controller.dart';
import 'core/controllers/movie_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/discover/discover_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/result/movie_result_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configura orientação e status bar
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CineMatchApp());
}

class CineMatchApp extends StatelessWidget {
  const CineMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CineMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Inicialização dos controllers
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
        Get.put(MovieController(), permanent: true);
      }),

      // Rotas
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/signup',
          page: () => SignUpScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/home',
          page: () => const MainShell(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/discover',
          page: () => const DiscoverScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/result',
          page: () => const MovieResultScreen(),
          transition: Transition.zoom,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          transition: Transition.rightToLeft,
        ),
      ],

      // Configurações de navegação
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
