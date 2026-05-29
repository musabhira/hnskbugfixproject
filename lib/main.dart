import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
import 'services/shorebird_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize core application services with a timeout to prevent hanging
  try {
    debugPrint('Main: Starting core service initialization...');
    await Future.wait([
      SupaFlow.initialize().then((_) => debugPrint('Main: SupaFlow initialized.')),
      LocalSyncServer().initialize().then((_) => debugPrint('Main: LocalSyncServer initialized.')),
      FlutterFlowTheme.initialize().then((_) => debugPrint('Main: FlutterFlowTheme initialized.')),
      ShorebirdService().initialize().then((_) => debugPrint('Main: ShorebirdService initialized.')),
    ]).timeout(const Duration(seconds: 10), onTimeout: () {
      debugPrint('Core service initialization timed out. Proceeding anyway...');
      return [];
    });
    debugPrint('Main: Core service initialization complete or timed out.');
  } catch (e) {
    debugPrint('Core service initialization error: $e');
  }

  // Start optional services in the background without blocking the UI
  final isFirebaseSupported = kIsWeb || 
      (defaultTargetPlatform == TargetPlatform.android || 
       defaultTargetPlatform == TargetPlatform.iOS || 
       defaultTargetPlatform == TargetPlatform.macOS);

  if (isFirebaseSupported) {
    unawaited(Firebase.initializeApp().then((_) {
      PushNotificationService.initialize();
    }).catchError((e) {
      debugPrint('Optional service error: $e');
      return null;
    }));
  } else {
    debugPrint('Firebase is not supported on this platform ($defaultTargetPlatform). Skipping initialization.');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class MyAppScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
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
          PushNotificationService.initialize();
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
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: ProviderScope(
        child: FluentApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Handskill Friends',
          scrollBehavior: MyAppScrollBehavior(),
          localizationsDelegates: const [
            FluentLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          theme: FluentThemeData(
            brightness: Brightness.light,
            accentColor: Colors.blue,
          ),
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.blue,
            scaffoldBackgroundColor: Colors.black,
          ),
          themeMode: _themeMode,
          routerConfig: _router,
        ),
      ),
    );
  }
}
