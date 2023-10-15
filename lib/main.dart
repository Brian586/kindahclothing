import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kindah/Ads/ad_state.dart';
import 'package:kindah/config.dart';
import 'package:kindah/pages/user_selector.dart';
import 'package:kindah/providers/account_provider.dart';
import 'package:kindah/providers/admin_provider.dart';
import 'package:kindah/providers/category_provider.dart';
import 'package:kindah/providers/product_provider.dart';
import 'package:kindah/providers/uniform_provider.dart';
import 'package:kindah/routes.dart';
import 'package:provider/provider.dart';
// import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Import the generated file
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initFuture = MobileAds.instance.initialize();
  var adState = AdState(initFuture);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  usePathUrlStrategy();

  runApp(MultiProvider(
    providers: [
      //Provider.value(value: adState),
      ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider()),
      ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),
      ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider()),
      ChangeNotifierProvider<AccountProvider>(create: (_) => AccountProvider()),
      ChangeNotifierProvider<UniformProvider>(create: (_) => UniformProvider())
    ],
    child: kIsWeb
        ? const MyApp()
        : Provider.value(
            value: adState,
            child: const MyApp(),
          ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: Config.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: customPrimaryColor,
      ),
      routerConfig: CustomRoutes.router,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    displaySplash();
  }

  void displaySplash() async {
    Timer(const Duration(seconds: 3), () async {
      // Ask for destination
      String destination = await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UserSelector()));

      // Proceed to destination

      GoRouter.of(context).go(destination);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Hero(
          tag: "assets/images/logo.png",
          child: Image.asset(
            "assets/images/logo.png",
            width: 300.0,
          ),
        ),
      ),
    );
  }
}
