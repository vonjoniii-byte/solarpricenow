// LeadForm — §3.4 / §2.3.3 of UX_SPEC.md
// Lead capture form with 4 fields + honeypot.

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/app_theme.dart';

/// Data returned on valid form submission.
class LeadFormData {
  final String name;
  final String email;
  final String phone;
  final String postcode;

  const LeadFormData({
    required this.name,
    required this.email,
    required this.phone,
    required this.postcode,
  });
}

class LeadForm extends StatefulWidget {
  final Future<void> Function(LeadFormData data) onSubmit;
  final bool isLoading;
  final String? apiError;
  final String submitLabel;

  const LeadForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.apiError,
    this.submitLabel = 'See My Recommendation',
  });

  @override
  State<LeadForm> createState() => LeadFormState();
}

class LeadFormState extends State<LeadForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _honeypotController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _postcodeController.dispose();
    _honeypotController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validators — exact error messages from UX_SPEC.md §8.6
  // ---------------------------------------------------------------------------

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your full name.';
    if (value.trim().length < 2) return 'Name must be at least 2 characters.';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address.';
    }
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number.';
    }
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Please enter a 10-digit Australian mobile number.';
    }
    // Valid AU prefixes: 04, 05, 02, 03, 07, 08
    final RegExp prefixRegex = RegExp(r'^0[234578]');
    if (!prefixRegex.hasMatch(digits)) {
      return 'Please enter a valid Australian phone number (e.g. 04XX XXX XXX).';
    }
    return null;
  }

  String? _validatePostcode(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your postcode.';
    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Please enter a valid 4-digit Australian postcode.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _handleSubmit() async {
    // Honeypot check — silent drop on client side
    if (_honeypotController.text.isNotEmpty) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await widget.onSubmit(
      LeadFormData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
        postcode: _postcodeController.text.trim(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              _buildField(
                controller: _nameController,
                label: 'Full name',
                hint: 'Your full name',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
                enabled: !widget.isLoading,
              ),
              const SizedBox(height: AppSpacing.fieldGap),

              // Email field
              _buildField(
                controller: _emailController,
                label: 'Email address',
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
                enabled: !widget.isLoading,
              ),
              const SizedBox(height: AppSpacing.fieldGap),

              // Phone field
              _buildField(
                controller: _phoneController,
                label: 'Mobile number',
                hint: '04XX XXX XXX',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                enabled: !widget.isLoading,
              ),
              const SizedBox(height: AppSpacing.fieldGap),

              // Postcode field
              _buildField(
                controller: _postcodeController,
                label: 'Postcode',
                hint: '0000',
                keyboardType: TextInputType.number,
                validator: _validatePostcode,
                enabled: !widget.isLoading,
                maxLength: 4,
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // API error banner
              if (widget.apiError != null)
                Semantics(
                  liveRegion: true,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBackground,
                      border:
                          Border.all(color: AppColors.errorBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.apiError!,
                            style: const TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Submit button
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    disabledBackgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radiusButton),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: widget.isLoading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.surface,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            key: const ValueKey('label'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.submitLabel,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.buttonLabel,
                                ),
                              ),
                              const SizedBox(width: 9),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Honeypot field — off-screen, invisible to human users
        Positioned(
          top: -9999,
          left: -9999,
          child: SizedBox(
            width: 1,
            height: 1,
            child: ExcludeSemantics(
              child: TextFormField(
                controller: _honeypotController,
                autocorrect: false,
                enableSuggestions: false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    bool enabled = true,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Semantics(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        enabled: enabled,
        maxLength: maxLength,
        validator: validator,
        autovalidateMode: AutovalidateMode.disabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          counterText: '',
          errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        ),
      ),
    );
  }
}
