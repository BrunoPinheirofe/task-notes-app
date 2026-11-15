import 'package:app/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    this.onAuthenticated,
    super.key,
  });

  final void Function(String username)? onAuthenticated;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);

    final username = _usernameController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLogin ? 'Bem-vindo de volta!' : 'Conta criada com sucesso!',
        ),
      ),
    );
    widget.onAuthenticated?.call(username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.cardBackGround,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Circle
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.bookOpen,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        'Meu Caderno',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimary,
                            ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      const Text(
                        'Suas tarefas e notas organizadas em um só lugar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.onMuted,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Username
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Usuário',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(fontFamily: 'Lora', fontSize: 14),
                        decoration: _inputDecoration('Seu nome de usuário'),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Informe seu usuário'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Senha',
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(fontFamily: 'Lora', fontSize: 14),
                        decoration: _inputDecoration('••••••••'),
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Informe sua senha'
                            : null,
                      ),
                      const SizedBox(height: 22),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading) ...[
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                _isLogin ? 'Entrar' : 'Criar Conta',
                                style: const TextStyle(
                                  fontFamily: 'Lora',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Toggle Login/Register
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            _isLogin
                                ? 'Ainda não tem uma conta?'
                                : 'Já possui uma conta?',
                            style: const TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 13,
                              color: AppColors.onMuted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin ? 'Cadastre-se' : 'Faça Login',
                              style: const TextStyle(
                                fontFamily: 'Lora',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
