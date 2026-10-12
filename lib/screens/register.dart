import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../core/auth_repository.dart';
import '../core/auth_storage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repository = AuthRepository();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await _repository.register(
        email: email,
        password: password,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      // Register doesn't return a token, so log in right away with the same
      // credentials instead of dropping the user back at a login form.
      final result = await _repository.login(email: email, password: password);
      if (!mounted) return;
      context.read<AuthBloc>().add(
        LoggedIn(AuthSession(token: result.token, user: result.user)),
      );
      Navigator.of(
        context,
      ).pop(); // back to LoginScreen, whose listener pops it too
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  helperText: 'At least 8 characters',
                ),
                validator: (value) => (value == null || value.length < 8)
                    ? 'Must be at least 8 characters'
                    : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
