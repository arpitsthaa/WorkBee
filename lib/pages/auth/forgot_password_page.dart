import 'package:flutter/material.dart';
import '../../auth_widgets.dart';
import '../../auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await WorkBeeAuthService.post(
      'forgot-password/',
      {'email': _emailController.text.trim().toLowerCase()},
      defaultSuccessMessage:
      'If an account exists, a reset link has been sent.',
      defaultErrorMessage: 'Failed to send reset link',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      WorkBeeAuthService.showSnackBar(context, result.message);
      Navigator.pop(context);
    } else {
      WorkBeeAuthService.showSnackBar(context, result.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkBeeTheme.lightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WorkBeeBrandHeader(),
                    const SizedBox(height: 28),
                    const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: WorkBeeTheme.darkNavy,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'No worries. Enter the email linked to your WorkBee account and we’ll send you a password reset link.',
                      style: TextStyle(
                        fontSize: 14,
                        color: WorkBeeTheme.slateMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    WorkBeeSectionCard(
                      title: 'Account Recovery',
                      sectionIcon: Icons.mark_email_unread_outlined,
                      accentColor: WorkBeeTheme.primaryBlue,
                      children: [
                        WorkBeeTextField(
                          label: 'Email',
                          hintText: 'Enter your registered email',
                          controller: _emailController,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: WorkBeeAuthService.validateEmail,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    WorkBeePrimaryButton(
                      text: 'Send reset link',
                      isLoading: _isLoading,
                      onPressed: _sendResetLink,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: WorkBeeTheme.primaryBlue,
                        ),
                        label: const Text(
                          'Back to log in',
                          style: TextStyle(
                            color: WorkBeeTheme.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: WorkBeeTheme.borderColor),
                    const SizedBox(height: 16),
                    const Text(
                      'Can’t find the email?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: WorkBeeTheme.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Check your spam folder, or make sure you’ve entered the email you used to register.',
                      style: TextStyle(
                        fontSize: 13,
                        color: WorkBeeTheme.slateMuted,
                        height: 1.4,
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