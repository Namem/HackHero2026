import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/aura_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _ecaAccepted = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      final role = auth.role;
      if (role == 'parent') {
        Navigator.pushReplacementNamed(context, Routes.parentHome);
      } else if (role == 'child') {
        Navigator.pushReplacementNamed(context, Routes.childHome);
      } else {
        Navigator.pushReplacementNamed(context, Routes.roleSelect);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Erro ao entrar'), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    const AuraLogo(size: 80),
                    const SizedBox(height: 16),
                    const Text(
                      'Aura',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Proteção digital com inteligência',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 36),

                    // Form card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('E-MAIL'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _emailCtrl,
                            icon: Icons.mail_outline,
                            hint: 'seu@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('SENHA'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _passCtrl,
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            obscure: _obscure,
                            validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ECA notice
                          Container(
                            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.1),
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _ecaAccepted = !_ecaAccepted),
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 1),
                                    decoration: BoxDecoration(
                                      color: _ecaAccepted ? AppTheme.accent : Colors.transparent,
                                      border: Border.all(
                                        color: _ecaAccepted ? AppTheme.accent : Colors.white.withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: _ecaAccepted
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Aviso legal · ECA Digital',
                                        style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Você se compromete a informar a criança sobre o monitoramento.',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.5),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Lei 15.211/2025, Art. 19 §1º',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: auth.loading
                                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                : ElevatedButton(
                                    onPressed: _login,
                                    child: const Text('Entrar', style: TextStyle(fontSize: 15)),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, Routes.register),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6)),
                                  children: const [
                                    TextSpan(text: 'Não tem conta? '),
                                    TextSpan(
                                      text: 'Cadastrar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Aura · Hackathon HackerHero 2026',
                        style: TextStyle(fontSize: 10.5, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.white.withValues(alpha: 0.55)),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
        errorStyle: const TextStyle(color: AppTheme.danger),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
