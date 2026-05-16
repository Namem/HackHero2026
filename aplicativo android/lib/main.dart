import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/link_provider.dart';
import 'providers/apps_provider.dart';
import 'providers/triggers_provider.dart';
import 'providers/alerts_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/role_select_screen.dart';
import 'screens/pairing/parent_generate_code_screen.dart';
import 'screens/pairing/child_enter_code_screen.dart';
import 'screens/parent/parent_home_screen.dart';
import 'screens/parent/alerts_list_screen.dart';
import 'screens/parent/alert_detail_screen.dart';
import 'screens/parent/select_apps_screen.dart';
import 'screens/parent/triggers_screen.dart';
import 'screens/parent/trigger_edit_screen.dart';
import 'screens/child/child_consent_screen.dart';
import 'screens/child/child_permissions_screen.dart';
import 'screens/child/child_home_screen.dart';
import 'screens/child/child_apps_list_screen.dart';
import 'screens/child/child_simulate_screen.dart';

void main() {
  runApp(const VigiliaApp());
}

class VigiliaApp extends StatelessWidget {
  const VigiliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LinkProvider()),
        ChangeNotifierProvider(create: (_) => AppsProvider()),
        ChangeNotifierProvider(create: (_) => TriggersProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
      ],
      child: MaterialApp(
        title: 'Vigília',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splash,
        routes: {
          Routes.splash: (_) => const SplashScreen(),
          Routes.login: (_) => const LoginScreen(),
          Routes.register: (_) => const RegisterScreen(),
          Routes.roleSelect: (_) => const RoleSelectScreen(),
          Routes.parentGenerateCode: (_) => const ParentGenerateCodeScreen(),
          Routes.parentHome: (_) => const ParentHomeScreen(),
          Routes.alertsList: (_) => const AlertsListScreen(),
          Routes.alertDetail: (_) => const AlertDetailScreen(),
          Routes.selectApps: (_) => const SelectAppsScreen(),
          Routes.triggers: (_) => const TriggersScreen(),
          Routes.triggerEdit: (_) => const TriggerEditScreen(),
          Routes.childConsent: (_) => const ChildConsentScreen(),
          Routes.childPermissions: (_) => const ChildPermissionsScreen(),
          Routes.childEnterCode: (_) => const ChildEnterCodeScreen(),
          Routes.childHome: (_) => const ChildHomeScreen(),
          Routes.childAppsList: (_) => const ChildAppsListScreen(),
          Routes.childSimulate: (_) => const ChildSimulateScreen(),
        },
      ),
    );
  }
}
