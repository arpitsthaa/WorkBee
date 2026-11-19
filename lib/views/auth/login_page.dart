import 'package:flutter/material.dart';
import '../../widgets/auth_widgets.dart';
import '../../services/auth_service.dart';
import '../../controllers/auth_controller.dart';
import '../student/dashboard_page.dart';
import 'student_register_page.dart';
import 'forgot_password_page.dart';
import 'business_register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = AuthController();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _controller.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (result.success && result.data != null) {
      final accessToken = result.data!['access'];
      final userType = result.data!['user_type'] ?? 'student';

      if (userType == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentDashboardPage(accessToken: accessToken),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business dashboard is coming soon.'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkBeeTheme.lightBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WorkBeeBrandHeader(),
                    const SizedBox(height: 36),
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: WorkBeeTheme.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bee Busy Be Paid',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: WorkBeeTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Connect with opportunities across Nepal.',
                      style: TextStyle(
                        fontSize: 14,
                        color: WorkBeeTheme.slateMuted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    WorkBeeTextField(
                      label: 'Email',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      fillColor: Colors.white,
                      validator: WorkBeeAuthService.validateEmail,
                    ),
                    const SizedBox(height: 20),
                    WorkBeeTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      fillColor: Colors.white,
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Please enter your password'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _controller.isLoading
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: WorkBeeTheme.primaryBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    WorkBeePrimaryButton(
                      text: 'Log in',
                      isLoading: _controller.isLoading,
                      onPressed: _onLoginPressed,
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        'New to WorkBee? Register as:',
                        style: TextStyle(
                          color: WorkBeeTheme.slateMuted,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleOutlineButton(
                      label: 'Student Registration',
                      icon: Icons.school_outlined,
                      iconColor: WorkBeeTheme.primaryBlue,
                      destination: const StudentRegistrationPage(),
                    ),
                    const SizedBox(height: 12),
                    _buildRoleOutlineButton(
                      label: 'Business Registration',
                      icon: Icons.storefront_outlined,
                      iconColor: WorkBeeTheme.businessAmber,
                      destination: const BusinessRegistrationPage(),
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

  Widget _buildRoleOutlineButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Widget destination,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: _controller.isLoading
            ? null
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: WorkBeeTheme.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: WorkBeeTheme.darkNavy,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}