import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

import 'auth/supabase_auth/supabase_user_provider.dart';
import 'auth/supabase_auth/auth_util.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'custom_code/services/local_sync_server.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialize core application services with a timeout to prevent hanging
  try {
    await Future.wait([
      SupaFlow.initialize(),
      LocalSyncServer().initialize(),
      FlutterFlowTheme.initialize(),
    ]).timeout(const Duration(seconds: 5), onTimeout: () {
      debugPrint('Core service initialization timed out. Proceeding anyway...');
      return [];
    });
  } catch (e) {
    debugPrint('Core service initialization error: $e');
  }

  // Start optional services in the background without blocking the UI
  unawaited(Firebase.initializeApp().then((_) {
    PushNotificationService.initialize();
  }).catchError((e) {
    debugPrint('Optional service error: $e');
    return null;
  }));

  runApp(const ProviderScope(child: MyApp()));
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
        _appStateNotifier.update(user);
        if (user.loggedIn) {
          PushNotificationService.initialize();
        }
        // Dismiss splash as soon as we have a user state
        if (_appStateNotifier.showSplashImage) {
          _appStateNotifier.stopShowingSplashImage();
        }
      });
    jwtTokenStream.listen((_) {});
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
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
    );
  }
}
