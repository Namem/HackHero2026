import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/aura_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    // Garante que a splash nunca trava: se restore demorar > 5s, vai pra login
    final restored = await auth
        .tryRestoreSession()
        .timeout(const Duration(seconds: 5), onTimeout: () => false);

    if (!mounted) return;

    if (!restored) {
      Navigator.pushReplacementNamed(context, Routes.login);
      return;
    }

    final role = auth.role;
    if (role == 'parent') {
      Navigator.pushReplacementNamed(context, Routes.parentHome);
    } else if (role == 'child') {
      Navigator.pushReplacementNamed(context, Routes.childHome);
    } else {
      Navigator.pushReplacementNamed(context, Routes.roleSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuraLogo(size: 100),
            const SizedBox(height: 20),
            const Text(
              'Aura',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Proteção digital com inteligência',
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppTheme.primaryLight,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
