import 'package:blogman/commons/extensions/theme.dart';
import 'package:blogman/ui/views/auth/auth_viewmodel.dart';
import 'package:blogman/ui/views/profile/profile_viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await EasyLocalization.ensureInitialized();
  setupLocator();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      child: const Main(),
    ),
  );
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
            create: (context) => locator<AuthViewModel>()),
        ChangeNotifierProvider<ProfileViewModel>(
            create: (context) => locator<ProfileViewModel>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: context.themeData(),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: router,
      ),
    );
  }
}
