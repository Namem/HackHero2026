import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

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
    final restored = await auth.tryRestoreSession();

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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 80, color: AppTheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Vigília',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Monitoramento parental com IA',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
