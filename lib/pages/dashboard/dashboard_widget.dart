import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  static const String routeName = 'dashboard';
  static const String routePath = '/dashboard';

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userName = 'Usuario Kellogg\'s';
  String _userEmail = 'usuario@kelloggs.com';
  String _userRole = 'Empleado';

  final List<DashboardItem> _dashboardItems = [
    DashboardItem(
      title: 'Tiendas',
      icon: Icons.store,
      color: Colors.blue,
      route: '/stores',
    ),
    DashboardItem(
      title: 'Productos',
      icon: Icons.shopping_bag,
      color: Colors.green,
      route: '/products',
    ),
    DashboardItem(
      title: 'Rutas',
      icon: Icons.route,
      color: Colors.orange,
      route: '/routes',
    ),
    DashboardItem(
      title: 'Dinámica Comercial',
      icon: Icons.bar_chart,
      color: Colors.purple,
      route: '/commercial',
    ),
    DashboardItem(
      title: 'Espacios Adicionales',
      icon: Icons.space_dashboard,
      color: Colors.teal,
      route: '/spaces',
    ),
    DashboardItem(
      title: 'Visitas',
      icon: Icons.calendar_today,
      color: Colors.pink,
      route: '/visits',
    ),
    DashboardItem(
      title: 'Reportes',
      icon: Icons.assessment,
      color: Colors.blueGrey,
      route: '/reports',
    ),
    DashboardItem(
      title: 'Usuarios',
      icon: Icons.people,
      color: Colors.brown,
      route: '/users',
    ),
    DashboardItem(
      title: 'Configuraciones',
      icon: Icons.settings,
      color: Colors.grey,
      route: '/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Text(
          'Panel Kellogg\'s',
          style: FlutterFlowTheme.of(context).title2.override(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 22,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // TODO: Implement logout
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Color(0x33000000),
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: FlutterFlowTheme.of(context).title3.override(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                            ),
                      ),
                      Text(
                        _userEmail,
                        style: FlutterFlowTheme.of(context).bodyText2,
                      ),
                      Text(
                        _userRole,
                        style: FlutterFlowTheme.of(context).bodyText1.override(
                              fontFamily: 'Poppins',
                              color: FlutterFlowTheme.of(context).primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dashboard Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = _dashboardItems[index];
                  return _DashboardCard(
                    title: item.title,
                    icon: item.icon,
                    color: item.color,
                    onTap: () {
                      if (item.route.isNotEmpty) {
                        context.push(item.route);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement quick action
        },
        backgroundColor: FlutterFlowTheme.of(context).primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).subtitle2.override(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
