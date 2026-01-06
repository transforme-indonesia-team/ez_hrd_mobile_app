import 'package:flutter/material.dart';
import 'package:hrd_app/features/auth/widgets/email_sent_form.dart';

class EmailSentScreen extends StatelessWidget {
  final String email;

  const EmailSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: EmailSentForm(email: email),
            ),
          ),
        ),
      ),
    );
  }
}
