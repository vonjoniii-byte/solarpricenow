// Step 1 — Input Screen (/). Imported design: three "Question" sections
// (bill / setup / usage) + "See my savings" CTA. Real engine call preserved.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../engine/enums.dart';
import '../state/funnel_controller.dart';
import '../services/analytics.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/bill_slider.dart';
import '../widgets/option_card.dart';
import '../widgets/app_header.dart';

class Step1InputScreen extends StatefulWidget {
  const Step1InputScreen({super.key});

  @override
  State<Step1InputScreen> createState() => _Step1InputScreenState();
}

class _Step1InputScreenState extends State<Step1InputScreen> {
  double _bill = 600.0;
  SetupType? _setup;
  UsagePattern? _pattern;

  void _onBillChanged(double value) {
    _bill = value;
    _syncController();
  }

  void _onSetupSelected(SetupType setup) {
    setState(() => _setup = setup);
    _syncController();
  }

  void _onPatternSelected(UsagePattern pattern) {
    setState(() => _pattern = pattern);
    _syncController();
  }

  void _syncController() {
    if (_setup != null && _pattern != null) {
      context.read<FunnelController>().setInput(
            bill2month: _bill,
            setup: _setup!,
            pattern: _pattern!,
          );
    }
  }

  bool get _isComplete => _setup != null && _pattern != null;

  void _onCalculate() {
    // Q2 and Q3 are now required — the button is disabled until both are
    // answered, so this should only ever fire when _isComplete is true.
    // Guard kept defensively in case of a future call-site change.
    if (!_isComplete) return;

    final controller = context.read<FunnelController>();
    controller.setInput(bill2month: _bill, setup: _setup!, pattern: _pattern!);
    // Calculation itself now runs on the /calculating screen (it's what
    // drives the "answer's ready" moment at the end of that animation).
    Analytics.trackStep1Calculate();
    context.push('/calculating');
  }

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
                    const SizedBox(height: 8),
                    const StepProgressIndicator(
                        currentStep: 1, stepName: 'About your home'),
                    const SizedBox(height: 22),

                    Text('Get your solar price in under a minute.',
                        style: AppTypography.display),
                    const SizedBox(height: 6),
                    Text(
                      'Three quick questions. Your estimate appears instantly — '
                      'no sign-up, no obligation.',
                      style: AppTypography.body
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    _section(
                      eyebrow: 'Question 1',
                      title: 'Your average electricity bill',
                      child: BillSlider(
                        initialValue: _bill,
                        onChanged: _onBillChanged,
                        onSubmitted: _onBillChanged,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _section(
                      eyebrow: 'Question 2',
                      title: "What's on your roof today?",
                      child: _cards(_setupCards()),
                    ),
                    const SizedBox(height: 16),

                    _section(
                      eyebrow: 'Question 3',
                      title: 'When do you use the most power?',
                      child: _cards(_usageCards()),
                    ),
                    const SizedBox(height: 22),

                  _primaryButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String eyebrow,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: shadowCard,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(), style: AppTypography.captionUppercase),
          const SizedBox(height: 4),
          Text(title, style: AppTypography.h3),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _cards(List<Widget> cards) {
    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          cards[i],
          if (i < cards.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  List<Widget> _setupCards() => [
        OptionCard(
          icon: Icons.bolt_rounded,
          title: 'Nothing yet',
          description: 'Starting fresh',
          isSelected: _setup == SetupType.nothing,
          onTap: () => _onSetupSelected(SetupType.nothing),
          semanticsLabel:
              'Nothing yet. Starting fresh. ${_setup == SetupType.nothing ? "Selected." : ""}',
        ),
        OptionCard(
          icon: Icons.solar_power_rounded,
          title: 'Panels only',
          description: 'No battery yet',
          isSelected: _setup == SetupType.panelsOnly,
          onTap: () => _onSetupSelected(SetupType.panelsOnly),
          semanticsLabel:
              'Panels only. No battery yet. ${_setup == SetupType.panelsOnly ? "Selected." : ""}',
        ),
        OptionCard(
          icon: Icons.battery_charging_full_rounded,
          title: 'Panels & battery',
          description: 'Already set up',
          isSelected: _setup == SetupType.panelsAndBattery,
          onTap: () => _onSetupSelected(SetupType.panelsAndBattery),
          semanticsLabel:
              'Panels and battery. Already set up. ${_setup == SetupType.panelsAndBattery ? "Selected." : ""}',
        ),
      ];

  List<Widget> _usageCards() => [
        OptionCard(
          icon: Icons.wb_sunny_rounded,
          title: 'Mostly daytime',
          description: 'Home during the day',
          isSelected: _pattern == UsagePattern.mostlyDay,
          onTap: () => _onPatternSelected(UsagePattern.mostlyDay),
          semanticsLabel:
              'Mostly daytime. Home during the day. ${_pattern == UsagePattern.mostlyDay ? "Selected." : ""}',
        ),
        OptionCard(
          icon: Icons.schedule_rounded,
          title: 'A mix of both',
          description: 'Spread across the day',
          isSelected: _pattern == UsagePattern.evenSplit,
          onTap: () => _onPatternSelected(UsagePattern.evenSplit),
          semanticsLabel:
              'A mix of both. Spread across the day. ${_pattern == UsagePattern.evenSplit ? "Selected." : ""}',
        ),
        OptionCard(
          icon: Icons.bedtime_rounded,
          title: 'Mostly nights',
          description: 'Out during the day',
          isSelected: _pattern == UsagePattern.mostlyNight,
          onTap: () => _onPatternSelected(UsagePattern.mostlyNight),
          semanticsLabel:
              'Mostly nights. Out during the day. ${_pattern == UsagePattern.mostlyNight ? "Selected." : ""}',
        ),
      ];

  Widget _primaryButton() {
    final bool enabled = _isComplete;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: enabled
              ? 'Get my solar price now'
              : 'Get my solar price now. Answer questions 2 and 3 to continue.',
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: enabled ? _onCalculate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    enabled ? AppColors.primary : AppColors.borderDefault,
                foregroundColor:
                    enabled ? AppColors.textOnPrimary : AppColors.textMuted,
                disabledBackgroundColor: AppColors.borderDefault,
                disabledForegroundColor: AppColors.textMuted,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radiusButton),
                ),
                textStyle: AppTypography.buttonLabel,
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text('Get my solar price now',
                        style: AppTypography.buttonLabel,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 9),
                  Icon(Icons.arrow_forward_rounded,
                      size: 20,
                      color:
                          enabled ? AppColors.textOnPrimary : AppColors.textMuted),
                ],
              ),
            ),
          ),
        ),
        if (!enabled) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Answer questions 2 and 3 to continue',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

}
