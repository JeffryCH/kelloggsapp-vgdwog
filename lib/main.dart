import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'dart:async';

import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'dbHelper/mongodb.dart';

void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure GoRouter
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Show a loading indicator while initializing
  runApp(
    MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: _initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return _buildErrorScreen(snapshot.error);
              }
              return MyApp();
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    // Initialize theme first
    await FlutterFlowTheme.initialize();
    
    // Then initialize MongoDB
    await _initializeMongoDB();
  } catch (e) {
    print('App initialization failed: $e');
    rethrow;
  }
}

Widget _buildErrorScreen(dynamic error) {
  final isConnectionError = error.toString().toLowerCase().contains('internet');
  
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isConnectionError ? Icons.wifi_off : Icons.error_outline,
                color: isConnectionError ? Colors.orange : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                isConnectionError 
                    ? 'Sin conexión a Internet'
                    : 'Error de conexión',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isConnectionError
                    ? 'Por favor, verifica tu conexión a Internet y vuelve a intentarlo.'
                    : 'No se pudo conectar al servidor. Por favor, inténtalo de nuevo más tarde.',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              if (!isConnectionError) ...[
                const SizedBox(height: 24),
                const Text(
                  'Detalles del error:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  runApp(MyApp());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isConnectionError) ...[
                const Text(
                  'O verifica tu configuración de red.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _initializeMongoDB() async {
  try {
    print('🔄 Initializing MongoDB...');
    await MongoDB.init();
    print('✅ MongoDB initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize MongoDB: $e');
    // Re-throw to be caught by the error boundary
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    if (state == null) {
      throw FlutterError('_MyAppState not found in context');
    }
    return state;
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

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
      title: 'kelloggs app',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
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
