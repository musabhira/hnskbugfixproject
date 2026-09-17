import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'custom_code/services/local_sync_server.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/push_notification_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch synchronous framework-level errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Main: FlutterError caught: ${details.exceptionAsString()}');
    };

    // Catch asynchronous uncaught errors and prevent process termination
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Main: PlatformDispatcher caught uncaught error: $error\n$stack');
      return true; // Mark as handled to prevent native app crash dialog
    };

    if (kIsWeb) {
      usePathUrlStrategy();
    }

    // Initialize core application services sequentially to avoid race conditions
    try {
      debugPrint('Main: Starting core service initialization...');
      // 1. SupaFlow MUST be initialized first before anything accesses Supabase
      await SupaFlow.initialize().then((_) => debugPrint('Main: SupaFlow initialized.'));
      
      // 2. Initialize Theme
      await FlutterFlowTheme.initialize().then((_) => debugPrint('Main: FlutterFlowTheme initialized.'));

      // 3. Initialize LocalSyncServer safely
      try {
        await LocalSyncServer().initialize().then((_) => debugPrint('Main: LocalSyncServer initialized.'));
      } catch (e) {
        debugPrint('Main: LocalSyncServer initialization error: $e');
      }

      // Shorebird code push disabled per user requirement to prevent native startup crashes
      // await ShorebirdService().initialize();
      
      debugPrint('Main: Core service initialization complete.');
    } catch (e) {
      debugPrint('Core service initialization error: $e');
    }

    // Initialize Firebase in the background safely without blocking the UI
    final isFirebaseSupported = !kIsWeb && 
        (defaultTargetPlatform == TargetPlatform.android || 
         defaultTargetPlatform == TargetPlatform.iOS || 
         defaultTargetPlatform == TargetPlatform.macOS);

    if (isFirebaseSupported) {
      unawaited(() async {
        try {
          if (Firebase.apps.isEmpty) {
            await Firebase.initializeApp();
            debugPrint('Main: Firebase core initialized.');
          }
        } catch (e) {
          debugPrint('Main: Firebase core initialization error: $e');
        }
      }());
    } else {
      debugPrint('Firebase is not supported on this platform ($defaultTargetPlatform). Skipping initialization.');
    }

    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('Main: Global runZonedGuarded caught unhandled error: $error\n$stackTrace');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Key _key = UniqueKey();

  void restartApp() {
    safeSetState(() {
      _key = UniqueKey();
    });
  }

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatchBase? routeMatch]) {
    final RouteMatchBase lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  late Stream<BaseAuthUser> userStream;

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    // Safety fallback: Ensure splash is dismissed after 5 seconds regardless of other events
    Future.delayed(const Duration(seconds: 5), () {
      if (_appStateNotifier.showSplashImage) {
        debugPrint('Main: Forcing splash dismissal after 5s safety timeout.');
        _appStateNotifier.stopShowingSplashImage();
      }
    });

    userStream = pocketMatesAppSupabaseUserStream()
      ..listen((user) {
        debugPrint('Main: Auth state update. Logged in: ${user.loggedIn}');
        _appStateNotifier.update(user);
        
        // Only stop showing splash if we are logged in, 
        // OR if we've waited long enough to be sure the user is actually logged out.
        if (user.loggedIn) {
          debugPrint('Main: User is logged in. Dismissing splash.');
          _appStateNotifier.stopShowingSplashImage();
          try {
            PushNotificationService.initialize();
          } catch (e) {
            debugPrint('Main: PushNotificationService error on login: $e');
          }
        } else {
          // If not logged in, we give Supabase a tiny bit more time (500ms) 
          // to ensure it wasn't just a slow initial storage read.
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_appStateNotifier.loggedIn && _appStateNotifier.showSplashImage) {
              debugPrint('Main: User is confirmed logged out. Dismissing splash.');
              _appStateNotifier.stopShowingSplashImage();
            }
          });
        }
      }, onError: (e) {
        debugPrint('Main: User stream error: $e');
        _appStateNotifier.stopShowingSplashImage();
      });
    jwtTokenStream.listen((_) {});
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = ThemeMode.dark;
        FlutterFlowTheme.saveThemeMode(ThemeMode.dark);
      });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: ProviderScope(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'PoketMates',
          scrollBehavior: MyAppScrollBehavior(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
          ),
          themeMode: _themeMode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
