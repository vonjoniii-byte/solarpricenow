// Results Screen (/result) — imported design Step 2 (ungated).
// Shows the full recommendation INCLUDING real price/savings/payback with no
// personal details. Lead capture is secondary: "Book a free phone consultation"
// (book mode) or "Email me this estimate" (quote mode) → /lead.
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

  void _goLead(String mode) {
    final controller = context.read<FunnelController>();
    controller.setLeadMode(mode);
    if (mode == 'book') {
      Analytics.trackCtaClick();
    } else {
      Analytics.trackLeadFormRevealed();
    }
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
        _hero(
          controller.systemLabel,
          chips: [
            if (reduction != null)
              _heroChip(Icons.trending_down_rounded, 'Est. $reduction% off your bill'),
          ],
        ),
        const SizedBox(height: 16),
        if (priced != null) ...[
          _metrics(priced),
          const SizedBox(height: 12),
          if (!priced.isStub && priced.price > 0) ...[
            _financeCaveat(),
            const SizedBox(height: 12),
          ],
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

  Widget _heroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: AppColors.primaryLight),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metrics(PricedResult priced) {
    final cards = <Widget>[
      _metricCard(Icons.savings_rounded, 'Estimated investment',
          _money(priced.price), 'after rebates',
          badge: priced.isStub ? const PriceStubBadge() : null),
      _comboCard(priced),
      _metricCard(Icons.event_repeat_rounded, 'Payback period',
          '${priced.paybackYears.toStringAsFixed(1)} yrs', 'to break even'),
      _financeCard(priced),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = AppSpacing.metricCardGap;
        final bool twoCol = constraints.maxWidth >= Breakpoints.compact;
        // Each card is given a fixed width (single column < 360px, else 2-up),
        // so the cards' internal flex children always have a bounded width.
        final double cardWidth =
            twoCol ? (constraints.maxWidth - gap) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  Widget _metricCard(IconData icon, String label, String value, String sub,
      {bool highlight = false, Widget? badge}) {
    return Container(
      width: double.infinity,
      height: AppSpacing.metricCardHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: shadowCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.metricCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: AppColors.textSecondary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            value,
            style: AppTypography.metricValue.copyWith(
              color: highlight ? AppColors.secondary : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(sub, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
          if (badge != null) ...[const SizedBox(height: 6), badge],
        ],
      ),
    );
  }

  /// Shared card shell (same styling as _metricCard) for the multi-figure cards.
  Widget _cardShell(List<Widget> children) {
    return Container(
      width: double.infinity,
      height: AppSpacing.metricCardHeight,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.borderDefault),
        boxShadow: shadowCard,
      ),
      padding: const EdgeInsets.all(AppSpacing.metricCardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _cardLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 19, color: AppColors.textSecondary),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption
                .copyWith(fontWeight: FontWeight.w600, height: 1.2),
          ),
        ),
      ],
    );
  }

  // Combined "Annual savings" + "Estimated bill after" card (both labelled).
  Widget _comboCard(PricedResult priced) {
    return _cardShell([
      _cardLabel(Icons.trending_up_rounded, 'Annual savings'),
      const SizedBox(height: 8),
      Text(
        '${_money(priced.annualSaving)} / yr',
        style: AppTypography.metricValue.copyWith(color: AppColors.secondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 10),
      Divider(height: 1, color: AppColors.line),
      const SizedBox(height: 8),
      Text(
        'BILL AFTER',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.captionUppercase
            .copyWith(color: AppColors.textSecondary, letterSpacing: 0.8),
      ),
      const SizedBox(height: 3),
      Text(
        '${_money(priced.estBillAfter2mo)} / 2 months',
        style: AppTypography.bodySemibold.copyWith(fontSize: 16),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ]);
  }

  // Financing card — indicative bi-monthly repayment, or "Available on quote".
  Widget _financeCard(PricedResult priced) {
    final FinanceResult? f =
        priced.isStub ? null : FinanceCalculator.compute(priced.price);
    if (f == null) {
      return _cardShell([
        _cardLabel(Icons.account_balance_rounded, 'Finance from'),
        const SizedBox(height: 11),
        Text('Available on quote',
            style: AppTypography.bodySemibold.copyWith(fontSize: 16)),
        const SizedBox(height: 3),
        Text('indicative repayment',
            style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
      ]);
    }
    return _cardShell([
      _cardLabel(Icons.account_balance_rounded, 'Finance from'),
      const SizedBox(height: 11),
      Text(
        _money(f.bimonthlyRepayment),
        style: AppTypography.metricValue.copyWith(color: AppColors.primary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 3),
      Text('/ 2 months',
          style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
    ]);
  }

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
            '(7.99% p.a. fixed, comparison rate 9.49% p.a., 10-year term, \$199 '
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
    return Column(
      children: [
        BookAssessmentCta(onTap: () => _goLead('book')),
        const SizedBox(height: 10),
        SecondaryCta(
          onTap: () => _goLead('quote'),
          label: 'Email me this estimate',
          icon: Icons.mail_outline_rounded,
        ),
      ],
    );
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
