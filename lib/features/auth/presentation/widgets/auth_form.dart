import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final bool isLogin;
  final void Function(String email, String password) onSubmit;
  final bool showDemoToggle;
  final VoidCallback? onDemoToggle;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
    this.showDemoToggle = false,
    this.onDemoToggle,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement form fields, validation, demo toggle
    return Column(
      children: [
        Text(isLogin ? 'Login Form' : 'Signup Form'),
        if (showDemoToggle)
          TextButton(
            onPressed: onDemoToggle,
            child: const Text('Use demo account'),
          ),
      ],
    );
  }
}
