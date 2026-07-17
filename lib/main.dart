import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/notification_service.dart';
import 'core/theme.dart';
import 'ui/screens/main_layout.dart';
import 'ui/screens/spend_summary_screen.dart';
import 'ui/screens/anomaly_alerts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await NotificationService.initialize();
  runApp(const ProviderScope(child: AdDashboardApp()));
}

class AdDashboardApp extends StatelessWidget {
  const AdDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ad Campaign Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainLayout(),
        '/summary': (context) => const SpendSummaryScreen(),
        '/alerts': (context) => const AnomalyAlertsScreen(),
      },
    );
  }
}
