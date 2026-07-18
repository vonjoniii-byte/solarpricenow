// Lead Screen (/lead) — imported design Step 3.
// Book-a-call lead capture → animated thank-you + "what happens next".
// Persistence/analytics wiring is identical to the prior inline flow.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/funnel_controller.dart';
import '../services/api_client.dart';
import '../services/analytics.dart';
import '../models/lead_model.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/lead_form.dart';
import '../widgets/app_header.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  bool _isLoading = false;
  String? _apiError;
  bool _leadSent = false;
  String _leadName = 'there';

  Future<void> _handleSubmit(LeadFormData formData) async {
    setState(() {
      _isLoading = true;
      _apiError = null;
    });

    final controller = context.read<FunnelController>();
    final rec = controller.recommendation;
    final priced = controller.pricedResult;
    final input = controller.input;

    if (rec == null || input == null) {
      setState(() {
        _isLoading = false;
        _apiError =
            'Something went wrong. Please check your connection and try again.';
      });
      return;
    }

    final lead = LeadModel(
      name: formData.name,
      email: formData.email,
      phone: formData.phone,
      postcode: formData.postcode,
      bill2month: input.bill2month,
      setup: input.setup,
      pattern: input.pattern,
      recommendedArray: rec.array,
      recommendedBattery: rec.battery,
      estimatedPrice: priced?.price,
      annualSaving: priced?.annualSaving,
      paybackYears: priced?.paybackYears,
      timestamp: DateTime.now().toIso8601String(),
      company: '',
      marketingOptIn: formData.marketingOptIn,
    );

    try {
      await ApiClient.submitLead(lead);
      Analytics.trackStep2LeadSubmitted();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _leadSent = true;
          _leadName = formData.name.split(' ').first;
        });
      }
    } on LeadSubmitException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _apiError =
              'Something went wrong. Please check your connection and try again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _apiError =
              'Something went wrong. Please check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeader(),
                    const SizedBox(height: 8),
                    const StepProgressIndicator(
                      currentStep: 3,
                      stepName: 'Book a call',
                    ),
                    const SizedBox(height: 18),
                    if (_leadSent) _confirmation() else _formView(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Book your free phone consultation',
          style: AppTypography.h1,
        ),
        const SizedBox(height: 6),
        Text(
          'A local specialist confirms your roof, usage and options over the '
          'phone, then finalises your exact price.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Text(
          "We'll share the details below with a solar consultant so they can "
          'follow up on your quote or booking. See our Privacy Policy for '
          'how your information is handled.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radiusCard),
            border: Border.all(color: AppColors.borderDefault),
            boxShadow: shadowCard,
          ),
          padding: const EdgeInsets.all(20),
          child: LeadForm(
            onSubmit: _handleSubmit,
            isLoading: _isLoading,
            apiError: _apiError,
            submitLabel: 'Request my call',
            onPrivacyPolicyTap: () => context.push('/privacy-policy'),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 15, color: AppColors.secondary),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                'Your details are kept secure and only used as described above.',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _backLink(),
      ],
    );
  }

  Widget _confirmation() {
    const String msg = 'Your request is in. A local specialist will call '
        'within one business day to lock in a time that suits you.';
    const List<String> steps = [
      'We call to confirm a time that suits you.',
      'A specialist talks through your roof, usage and options by phone.',
      'You get a clear, tailored recommendation — no obligation.',
    ];

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(radiusCard),
            border: Border.all(color: AppColors.borderDefault),
            boxShadow: shadowCard,
          ),
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 38, color: AppColors.secondary),
              ),
              const SizedBox(height: 18),
              Text('Thanks, $_leadName.',
                  textAlign: TextAlign.center, style: AppTypography.h1),
              const SizedBox(height: 8),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  borderRadius: BorderRadius.circular(radiusCardSm),
                ),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WHAT HAPPENS NEXT',
                        style: AppTypography.captionUppercase
                            .copyWith(letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    for (int i = 0; i < steps.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 23,
                              height: 23,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                    fontFamily: AppTypography.numFont,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textOnPrimary,
                                  )),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(steps[i],
                                    style: AppTypography.bodySmall.copyWith(
                                      fontSize: 13.5,
                                      color: AppColors.textPrimary,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _backLink(toResults: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _backLink({bool toResults = false}) {
    return Center(
      child: Semantics(
        button: true,
        label: 'Back to my estimate',
        child: TextButton.icon(
          onPressed: () => context.go('/result'),
          icon: const Icon(Icons.arrow_back_rounded,
              size: 17, color: AppColors.textSecondary),
          label: Text('Back to my estimate',
              style: AppTypography.bodySmall
                  .copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
