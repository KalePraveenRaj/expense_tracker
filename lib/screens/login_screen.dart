import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../theme/theme_notifier.dart';
import '../widgets/hover_elevated_card.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String? emailError;
  String? passError;

  bool loading = false;
  bool obscurePassword = true;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<void> login() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    setState(() {
      emailError = email.isEmpty
          ? 'Email is required'
          : !_isValidEmail(email)
              ? 'Enter a valid email'
              : null;

      passError = password.isEmpty ? 'Password is required' : null;
    });

    if (emailError != null || passError != null) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => loading = true);

    final result = await ApiService.login(email, password);

    if (!mounted) return;
    setState(() => loading = false);

    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userId: int.parse(result['user_id'].toString()),
            name: result['name'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    final isDark = theme.themeMode == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// 🌙 THEME TOGGLE
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: isDark ? 'Light mode' : 'Dark mode',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                onPressed: () => theme.toggle(!isDark),
              ),
            ),

            /// 🔐 LOGIN CARD (ELEVATED)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: HoverElevatedCard(
                    normalElevation: 4,
                    hoverElevation: 12,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// ICON
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              size: 44,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// EMAIL
                          TextField(
                            controller: emailCtrl,
                            onChanged: (_) => setState(() => emailError = null),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              errorText: emailError,
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// PASSWORD
                          TextField(
                            controller: passCtrl,
                            obscureText: obscurePassword,
                            onChanged: (_) => setState(() => passError = null),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.edit_note_outlined),
                              errorText: passError,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(() {
                                  obscurePassword = !obscurePassword;
                                }),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : login,
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Login'),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// REGISTER
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text('Create account'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
