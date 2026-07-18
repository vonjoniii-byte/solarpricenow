// Privacy Policy Screen (/privacy-policy)
// Plain-language policy covering the booking-step consent notice. Linked
// from LeadForm's consent checkbox. Content is a placeholder — replace with
// the finalised legal text before this goes live for real bookings.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Back',
                          child: IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('Privacy Policy', style: AppTypography.h1),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(radiusCard),
                        border: Border.all(color: AppColors.borderDefault),
                        boxShadow: shadowCard,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _section(
                            'What we collect',
                            'When you request a quote or book a call, we collect the '
                                'details you give us — your name, email, phone number, '
                                'postcode, and the property/usage details entered in the '
                                'estimate tool.',
                          ),
                          _section(
                            'How we use it',
                            'We use your details to prepare your solar estimate and to '
                                'put you in touch with a solar consultant or installer '
                                'partner for follow-up. We do not use your details for '
                                'any other purpose without telling you.',
                          ),
                          _section(
                            'Who we share it with',
                            'Your details may be shared with a solar consultant or '
                                'installer so they can contact you about your quote or '
                                'booking. We do not sell your details to third parties.',
                          ),
                          _section(
                            'Marketing',
                            'If you opt in to marketing updates, we may email or text '
                                'you occasionally about offers or news. You can opt out '
                                'at any time using the unsubscribe link or by contacting '
                                'us directly.',
                          ),
                          _section(
                            'Your choices',
                            'You can withdraw your consent at any time. Withdrawing '
                                'consent won\u2019t affect a quote or booking already in '
                                'progress, but we\u2019ll stop any further contact once '
                                'you let us know.',
                          ),
                          _section(
                            'Contact us',
                            'If you have questions about how your information is used, '
                                'get in touch and we\u2019ll help.',
                          ),
                        ],
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

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.h3),
          const SizedBox(height: 6),
          Text(body,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
