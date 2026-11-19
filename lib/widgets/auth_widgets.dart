import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WorkBeeTheme {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color borderColor = Color(0xFFD6DFED);
  static const Color iconTint = Color(0xFF8498B8);
  static const Color businessAmber = Color(0xFFD97706);
  static const Color successGreen = Color(0xFF16A34A);
}

class WorkBeeBrandHeader extends StatelessWidget {
  final Widget? trailingBadge;

  const WorkBeeBrandHeader({super.key, this.trailingBadge});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: WorkBeeTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'WorkBee',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: WorkBeeTheme.darkNavy,
              ),
            ),
          ],
        ),
        ?trailingBadge,
      ],
    );
  }
}

class WorkBeeRoleBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const WorkBeeRoleBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkBeeSectionCard extends StatelessWidget {
  final String title;
  final IconData sectionIcon;
  final Color accentColor;
  final List<Widget> children;

  const WorkBeeSectionCard({
    super.key,
    required this.title,
    required this.sectionIcon,
    required this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: WorkBeeTheme.borderColor.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: WorkBeeTheme.darkNavy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(sectionIcon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: WorkBeeTheme.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class WorkBeeTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool isPassword;
  final Color fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const WorkBeeTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.isPassword = false,
    this.fillColor = WorkBeeTheme.lightBg,
    this.inputFormatters,
    this.validator,
  });

  @override
  State<WorkBeeTextField> createState() => _WorkBeeTextFieldState();
}

class _WorkBeeTextFieldState extends State<WorkBeeTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: WorkBeeTheme.darkNavy,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          style: const TextStyle(fontSize: 14.5, color: WorkBeeTheme.darkNavy),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13.5,
            ),
            prefixIcon: Icon(
              widget.prefixIcon,
              color: WorkBeeTheme.iconTint,
              size: 20,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: WorkBeeTheme.iconTint,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
            filled: true,
            fillColor: widget.fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: WorkBeeTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: WorkBeeTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(
                color: WorkBeeTheme.primaryBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class WorkBeePrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool showArrow;

  const WorkBeePrimaryButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: WorkBeeTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: WorkBeeTheme.primaryBlue.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class WorkBeeBackToLoginLink extends StatelessWidget {
  final String promptText;

  const WorkBeeBackToLoginLink({
    super.key,
    this.promptText = 'Already have a WorkBee account? ',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: promptText,
          style: const TextStyle(
            color: WorkBeeTheme.slateMuted,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: 'Log in',
              style: const TextStyle(
                color: WorkBeeTheme.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.pop(context);
                },
            ),
          ],
        ),
      ),
    );
  }
}