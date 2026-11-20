import 'package:flutter/material.dart';
import '../../widgets/auth_widgets.dart';
import '../../services/auth_service.dart';
import '../../controllers/auth_controller.dart';

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  State<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final _controller = AuthController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _collegeController = TextEditingController();

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _onCreateAccountPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _controller.registerStudent(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      college: _collegeController.text,
    );

    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: WorkBeeTheme.successGreen,
        ),
      );
      Navigator.pop(context);
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
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const WorkBeeBrandHeader(
                      trailingBadge: WorkBeeRoleBadge(
                        label: 'For Students',
                        icon: Icons.school_rounded,
                        color: WorkBeeTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Student Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: WorkBeeTheme.darkNavy,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Find flexible micro gigs across Nepal and earn while you study.',
                      style: TextStyle(
                        fontSize: 14,
                        color: WorkBeeTheme.slateMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Card 1: Student Profile Details
                    WorkBeeSectionCard(
                      title: 'Academic & Personal Details',
                      sectionIcon: Icons.badge_outlined,
                      accentColor: WorkBeeTheme.primaryBlue,
                      children: [
                        WorkBeeTextField(
                          label: 'Full name',
                          hintText: 'Enter your full name',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator: (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'Please enter your full name'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'College / University',
                          hintText: 'e.g. Patan College for Professional Studies',
                          controller: _collegeController,
                          prefixIcon: Icons.account_balance_outlined,
                          textCapitalization: TextCapitalization.words,
                          validator: (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'Please enter your college or university'
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Card 2: Account Credentials
                    WorkBeeSectionCard(
                      title: 'Account Credentials',
                      sectionIcon: Icons.shield_outlined,
                      accentColor: WorkBeeTheme.primaryBlue,
                      children: [
                        WorkBeeTextField(
                          label: 'Email',
                          hintText: 'Enter your email address',
                          controller: _emailController,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: WorkBeeAuthService.validateEmail,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'Password',
                          hintText: 'Create a password (min. 8 characters)',
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please create a password';
                            }
                            if (val.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    WorkBeePrimaryButton(
                      text: 'Create Student Account',
                      isLoading: _controller.isLoading,
                      showArrow: true,
                      onPressed: _onCreateAccountPressed,
                    ),
                    const SizedBox(height: 20),
                    const WorkBeeBackToLoginLink(),
                    const SizedBox(height: 12),
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