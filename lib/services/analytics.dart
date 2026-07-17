// Analytics service stub — Phase 2 will wire real GA4 events.
// Stub implementation uses print() for visibility during development.

class Analytics {
  static void _track(String eventName) {
    // ignore: avoid_print
    print('[analytics] $eventName');
  }

  /// Fired when user taps "Calculate My Savings" on Step 1.
  static void trackStep1Calculate() => _track('funnel_step1_calculate');

  /// Fired when the (now ungated) results view is rendered.
  static void trackStep3View() => _track('funnel_step3_view');

  /// Fired when the user reveals the optional lead-capture form via the
  /// "Get a tailored quote" CTA (results are ungated, so this measures intent).
  static void trackLeadFormRevealed() => _track('funnel_lead_form_revealed');

  /// Fired when the lead form is submitted successfully (200 OK from API).
  static void trackStep2LeadSubmitted() => _track('funnel_step2_lead_submitted');

  /// Fired when the phone-consultation booking CTA is tapped.
  static void trackCtaClick() => _track('funnel_cta_click');
}
