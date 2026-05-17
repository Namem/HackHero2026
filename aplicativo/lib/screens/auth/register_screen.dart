import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa aceitar os Termos e a Política de Privacidade'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, Routes.roleSelect);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Erro ao cadastrar'), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Criar conta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cadastre-se como responsável',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 28),

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
                      _label('NOME COMPLETO'),
                      const SizedBox(height: 6),
                      _field(controller: _nameCtrl, icon: Icons.person_outline, hint: 'Maria Silva',
                          validator: (v) => (v == null || v.isEmpty) ? 'Informe seu nome' : null),
                      const SizedBox(height: 16),
                      _label('E-MAIL'),
                      const SizedBox(height: 6),
                      _field(controller: _emailCtrl, icon: Icons.mail_outline, hint: 'seu@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null),
                      const SizedBox(height: 16),
                      _label('SENHA'),
                      const SizedBox(height: 6),
                      _field(
                        controller: _passCtrl, icon: Icons.lock_outline, hint: '••••••••', obscure: _obscure,
                        validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                        suffix: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.white.withValues(alpha: 0.5), size: 20),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Aceite LGPD — obrigatório
                      GestureDetector(
                        onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _acceptedTerms
                                  ? AppTheme.accent.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: _acceptedTerms ? AppTheme.accent : Colors.transparent,
                                  border: Border.all(
                                    color: _acceptedTerms
                                        ? AppTheme.accent
                                        : Colors.white.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: _acceptedTerms
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Li e aceito os '),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, Routes.privacyPolicy),
                                          child: const Text(
                                            'Termos de Uso e a Política de Privacidade',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primaryLight,
                                              decoration: TextDecoration.underline,
                                              decorationColor: AppTheme.primaryLight,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: '. Sei exatamente quais dados o Aura coleta, como são armazenados e meus direitos sob a LGPD.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: auth.loading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : ElevatedButton(
                                onPressed: _acceptedTerms ? _register : null,
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                                  disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                                ),
                                child: const Text('Cadastrar'),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Já tenho conta', style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline, decorationColor: Colors.white.withValues(alpha: 0.5),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.white.withValues(alpha: 0.55)));
  }

  Widget _field({
    required TextEditingController controller, required IconData icon, required String hint,
    TextInputType? keyboardType, bool obscure = false, String? Function(String?)? validator, Widget? suffix,
  }) {
    return TextFormField(
      controller: controller, keyboardType: keyboardType, obscureText: obscure, validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 18), suffixIcon: suffix,
        filled: true, fillColor: Colors.black.withValues(alpha: 0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryLight, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.danger)),
        errorStyle: const TextStyle(color: AppTheme.danger),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
