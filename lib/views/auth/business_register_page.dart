import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/auth_widgets.dart';
import '../../services/auth_service.dart';
import '../../controllers/auth_controller.dart';

class BusinessRegistrationPage extends StatefulWidget {
  const BusinessRegistrationPage({super.key});

  @override
  State<BusinessRegistrationPage> createState() =>
      _BusinessRegistrationPageState();
}

class _BusinessRegistrationPageState extends State<BusinessRegistrationPage> {
  final _controller = AuthController();
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _panController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _panController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final result = await _controller.registerBusiness(
      businessName: _businessNameController.text,
      contactPerson: _contactPersonController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      panNumber: _panController.text,
      password: _passwordController.text,
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
                        label: 'For Employers',
                        icon: Icons.storefront_rounded,
                        color: WorkBeeTheme.businessAmber,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Business Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: WorkBeeTheme.darkNavy,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hire verified student talent across Nepal for quick projects and micro gigs.',
                      style: TextStyle(
                        fontSize: 14,
                        color: WorkBeeTheme.slateMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Card 1: Company Details
                    WorkBeeSectionCard(
                      title: 'Company & Verification Details',
                      sectionIcon: Icons.business_center_outlined,
                      accentColor: WorkBeeTheme.businessAmber,
                      children: [
                        WorkBeeTextField(
                          label: 'Business name',
                          hintText: 'e.g. Himalayan Tech Pvt. Ltd.',
                          controller: _businessNameController,
                          prefixIcon: Icons.store_mall_directory_outlined,
                          validator: (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'Business name is required'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'Contact person',
                          hintText: 'Full name of representative',
                          controller: _contactPersonController,
                          prefixIcon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                          validator: (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'Contact person is required'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'Location',
                          hintText: 'e.g. Baneshwor, Kathmandu',
                          controller: _locationController,
                          prefixIcon: Icons.location_on_outlined,
                          validator: (val) =>
                          (val == null || val.trim().isEmpty)
                              ? 'Location is required'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'PAN number',
                          hintText: '9 digit registered PAN',
                          controller: _panController,
                          prefixIcon: Icons.verified_user_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          validator: (val) =>
                          (val == null || val.trim().length != 9)
                              ? 'PAN number must be 9 digits'
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Card 2: Contact & Security
                    WorkBeeSectionCard(
                      title: 'Contact & Account Security',
                      sectionIcon: Icons.shield_outlined,
                      accentColor: WorkBeeTheme.primaryBlue,
                      children: [
                        WorkBeeTextField(
                          label: 'Business email',
                          hintText: 'name@company.com',
                          controller: _emailController,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: WorkBeeAuthService.validateEmail,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'Phone number',
                          hintText: '+977 98XXXXXXXX',
                          controller: _phoneController,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (val) =>
                          (val == null || val.trim().length < 10)
                              ? 'Enter a valid phone number'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'Password',
                          hintText: 'Min. 8 characters',
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (val) => (val == null || val.length < 8)
                              ? 'Password must be at least 8 characters'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        WorkBeeTextField(
                          label: 'Confirm password',
                          hintText: 'Re enter your password',
                          controller: _confirmPasswordController,
                          prefixIcon: Icons.lock_reset_outlined,
                          isPassword: true,
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Please confirm your password'
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    WorkBeePrimaryButton(
                      text: 'Create Business Account',
                      isLoading: _controller.isLoading,
                      showArrow: true,
                      onPressed: _registerBusiness,
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