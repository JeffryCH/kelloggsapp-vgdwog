import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:logging/logging.dart';

import 'dbHelper/mongodb.dart';
import 'repositories/user_repository.dart';
import 'services/auth_service.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

final _logger = Logger('main');

Future<void> main() async {
  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize URL strategy for web
    usePathUrlStrategy();
    
    // Initialize theme
    await FlutterFlowTheme.initialize();
    
    // Initialize services
    await _initializeServices();
    
    runApp(MyApp());
  } catch (e, stackTrace) {
    _logger.severe('Failed to initialize app', e, stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error al iniciar la aplicación: $e'),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeServices() async {
  try {
    _logger.info('🚀 Initializing services...');
    
    // 1. First initialize MongoDB
    _logger.info('🔌 Initializing MongoDB...');
    await MongoDB.init();
    
    // Verify MongoDB connection
    if (!MongoDB.isConnected) {
      throw Exception('Failed to connect to MongoDB');
    }
    _logger.info('✅ MongoDB initialized successfully');
    
    // Small delay to ensure database is ready
    await Future.delayed(const Duration(seconds: 1));
    
    // 2. Initialize repositories
    _logger.info('🔄 Initializing repositories...');
    await UserRepository.ensureCollection();
    
    // 3. Ensure admin user exists
    _logger.info('👤 Ensuring admin user exists...');
    final userRepo = UserRepository();
    await userRepo.ensureAdminUser();
    
    // 4. Initialize AuthService last
    _logger.info('🔑 Initializing AuthService...');
    final authService = AuthService();
    await authService.initialize();
    
    _logger.info('🎉 All services initialized successfully');
    
  } catch (e, stackTrace) {
    _logger.severe('❌ Error initializing services', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  final authService = AuthService();

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
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

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  void dispose() {
    // Close the MongoDB connection when the app is disposed
    MongoDB.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Kelloggs App',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}
