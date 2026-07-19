// Results Screen (/result) — imported design Step 2 (ungated).
// Shows the full recommendation INCLUDING real price/savings/payback with no
// personal details. Lead capture is secondary: "Book a free phone
// consultation" → /lead.
// Variant A = priced; Variant B = consult (real engine behaviour the design omits).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/funnel_controller.dart';
import '../models/priced_result.dart';
import '../pricing/finance_calculator.dart';
import '../services/analytics.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../widgets/price_stub_badge.dart';
import '../widgets/book_assessment_cta.dart';
import '../widgets/caveat_note.dart';
import '../widgets/app_header.dart';
import '../widgets/trust_section.dart';
import '../widgets/house_illustration.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Analytics.trackStep3View();
    });
  }

  void _goLead() {
    Analytics.trackCtaClick();
    context.push('/lead');
  }

  @override
  Widget build(BuildContext context) {
    final FunnelController controller = context.watch<FunnelController>();
    final PricedResult? priced = controller.pricedResult;
    final bool isConsult = controller.recommendation?.isConsult ?? true;

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
                        currentStep: 2, stepName: 'Your price'),
                    const SizedBox(height: 18),
                    if (isConsult)
                      _buildConsult(controller)
                    else
                      _buildPriced(controller, priced),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Variant A: priced ─────────────────────────────────────────────────────
  Widget _buildPriced(FunnelController controller, PricedResult? priced) {
    final int? reduction = controller.reductionPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _livePill(),
        const SizedBox(height: 14),
        _recommendedCard(controller, priced, reduction),
        const SizedBox(height: 12),
        if (priced != null && !priced.isStub && priced.price > 0) ...[
          _financeCaveat(),
          const SizedBox(height: 12),
        ],
        const CaveatNote(),
        const SizedBox(height: 20),
        _ctas(),
        const SizedBox(height: 13),
        _privacyLine('No obligation · We never sell your details'),
        const SizedBox(height: 22),
        const TrustSection(),
        const SizedBox(height: 18),
        _backLink('Adjust my answers', () {
          context.read<FunnelController>().reset();
          context.go('/');
        }),
      ],
    );
  }

  // ── Variant B: consult ────────────────────────────────────────────────────
  Widget _buildConsult(FunnelController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _hero('A tailored assessment is recommended', chips: const []),
        const SizedBox(height: 16),
        Text(
          'Your energy usage or existing setup means a standard package may not '
          'be the right fit. Book a free phone consultation and our team will '
          'talk through a solution tailored to your home — we only arrange a '
          'physical site assessment if it turns out you need one.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 22),
        _ctas(),
        const SizedBox(height: 13),
        _privacyLine('No obligation · We never sell your details'),
        const SizedBox(height: 22),
        const TrustSection(),
        const SizedBox(height: 18),
        _backLink('Adjust my answers', () {
          context.read<FunnelController>().reset();
          context.go('/');
        }),
      ],
    );
  }

  // ── Pieces ────────────────────────────────────────────────────────────────

  Widget _livePill() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, size: 15, color: AppColors.accent2),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Your live estimate — no sign-up needed',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Still used by the consult (Variant B) headline.
  Widget _hero(String label, {required List<Widget> chips}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(radiusCard),
        boxShadow: shadowCardElevated,
      ),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOMMENDED FOR YOUR HOME',
            style: AppTypography.captionUppercase.copyWith(
              color: AppColors.primaryLight,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.h1
                .copyWith(color: AppColors.textOnPrimary, fontSize: 30),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final chip in chips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                // Bound the chip so its inner Flexible text can ellipsize.
                child: Row(children: [Flexible(child: chip)]),
              ),
          ],
        ],
      ),
    );
  }

  // ── New recommended-system card (matches reference design) ─────────────────
  Widget _recommendedCard(
      FunnelController controller, PricedResult? priced, int? reduction) {
    final bool hasBattery =
        controller.systemLabel.toLowerCase().contains('battery');
    final FinanceResult? finance =
        (priced != null && !priced.isStub && priced.price > 0)
            ? FinanceCalculator.compute(priced.price)
            : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: shadowCardElevated,
      ),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your recommended system',
            textAlign: TextAlign.center,
            style: AppTypography.h1.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: HouseIllustration(
              hasSolar: true,
              hasBattery: hasBattery,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            controller.systemLabel,
            textAlign: TextAlign.center,
            style: AppTypography.h1.copyWith(fontSize: 27),
          ),
          const SizedBox(height: 4),
          Text(
            'Best match for your usage',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: AppColors.line),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Proudly installed by a trusted WA solar company',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.line),
          if (priced != null) ...[
            const SizedBox(height: 4),
            _metricsBlock(priced, reduction, finance),
          ],
        ],
      ),
    );
  }

  Widget _metricsBlock(
      PricedResult priced, int? reduction, FinanceResult? finance) {
    return Column(
      children: [
        _metricRow(
          icon: Icons.savings_rounded,
          label: 'Investment',
          value: _money(priced.price),
          trailingBadge: priced.isStub ? const PriceStubBadge() : null,
        ),
        _rowDivider(),
        _metricRow(
          icon: Icons.trending_up_rounded,
          label: 'Annual savings',
          value: _money(priced.annualSaving),
        ),
        _rowDivider(),
        _metricRow(
          icon: Icons.event_repeat_rounded,
          label: 'Payback',
          value: '${priced.paybackYears.toStringAsFixed(1)} years',
        ),
        if (reduction != null) ...[
          _rowDivider(),
          _metricRow(
            icon: Icons.trending_down_rounded,
            label: 'Bill reduction',
            value: '$reduction%',
          ),
        ],
        _rowDivider(),
        _metricRow(
          icon: Icons.credit_card_rounded,
          label: 'Finance option',
          value: finance != null
              ? 'From ${_money(finance.bimonthlyRepayment)} / 2mo'
              : 'Available on quote',
        ),
      ],
    );
  }

  Widget _metricRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailingBadge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.bodySemibold.copyWith(fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (trailingBadge != null) ...[
                const SizedBox(height: 4),
                trailingBadge,
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowDivider() => Divider(height: 1, color: AppColors.line);

  // Finance terms caveat — shown only when a repayment figure is displayed.
  Widget _financeCaveat() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Indicative only, based on the Brighte HEUF Discounted Green Loan '
            '(7.99% p.a. fixed, comparison rate 9.49% p.a., 10-year term, \$399 '
            'establishment fee, \$2.70/week account-keeping fee). Subject to '
            "credit approval; T&Cs apply. Confirm exact repayments via Brighte's "
            'calculator.',
            style: AppTypography.caption.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _ctas() {
    return BookAssessmentCta(onTap: _goLead);
  }

  Widget _privacyLine(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, size: 15, color: AppColors.secondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text,
              textAlign: TextAlign.center, style: AppTypography.caption),
        ),
      ],
    );
  }

  Widget _backLink(String label, VoidCallback onTap) {
    return Center(
      child: Semantics(
        button: true,
        label: label,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.arrow_back_rounded,
              size: 17, color: AppColors.textSecondary),
          label: Text(label,
              style: AppTypography.bodySmall
                  .copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  String _money(double value) {
    final int rounded = value.round();
    final String str = rounded.toString();
    final StringBuffer buf = StringBuffer('\$');
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}
