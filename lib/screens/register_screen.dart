import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/hover_elevated_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final salaryCtrl = TextEditingController();

  String? nameError;
  String? emailError;
  String? passError;
  String? salaryError;

  bool obscurePassword = true;
  bool loading = false;

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
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    salaryCtrl.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<void> register() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final salaryText = salaryCtrl.text.trim();

    setState(() {
      nameError = name.isEmpty ? 'Name is required' : null;
      emailError = email.isEmpty
          ? 'Email is required'
          : !_isValidEmail(email)
              ? 'Enter a valid email'
              : null;
      passError = password.isEmpty ? 'Password is required' : null;
      salaryError = salaryText.isEmpty
          ? 'Salary is required'
          : double.tryParse(salaryText) == null
              ? 'Enter a valid number'
              : null;
    });

    if (nameError != null ||
        emailError != null ||
        passError != null ||
        salaryError != null) {
      _shakeController.forward(from: 0);
      return;
    }

    setState(() => loading = true);

    final ok = await ApiService.register(
      name,
      email,
      password,
      double.parse(salaryText),
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
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
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_outlined,
                        size: 44,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// NAME
                    TextField(
                      controller: nameCtrl,
                      onChanged: (_) => setState(() => nameError = null),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: nameError,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// EMAIL
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
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
                          onPressed: () => setState(
                              () => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SALARY
                    TextField(
                      controller: salaryCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => salaryError = null),
                      decoration: InputDecoration(
                        labelText: 'Salary',
                        prefixIcon: const Icon(Icons.currency_rupee),
                        errorText: salaryError,
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Account'),
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
}
