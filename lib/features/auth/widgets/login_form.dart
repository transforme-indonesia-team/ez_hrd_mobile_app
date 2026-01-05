import 'package:flutter/material.dart';
import 'package:hrd_app/core/utils/validators.dart';
import 'package:hrd_app/data/services/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await AuthService().login(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang, ${user['name']}!'),
              backgroundColor: Colors.green,
            ),
          );
          debugPrint('Login sukses! Token: ${user['token']}');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            'assets/images/logo.jpeg',
            height: 80,
            width: 80,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'EZ HRD APP',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan login untuk melanjutkan',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 48),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: 30,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'nama@company.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) => Validators.email(value, maxLength: 30),
          ),
          const SizedBox(height: 16),
          // Password TextField
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: 30,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Masukkan password',
              prefixIcon: const Icon(Icons.lock_outlined),
              border: const OutlineInputBorder(),
              counterText: '',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) => Validators.password(value, maxLength: 30),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate ke halaman forgot password
              },
              child: const Text('Lupa Password?'),
            ),
          ),
          const SizedBox(height: 16),

          // Login Button
          FilledButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Login', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
