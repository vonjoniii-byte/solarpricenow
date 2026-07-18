// LeadForm widget tests — validation and submission.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_calculator/widgets/lead_form.dart';
import 'package:solar_calculator/theme/app_theme.dart';

void main() {
  Widget buildLeadForm({
    Future<void> Function(LeadFormData)? onSubmit,
    bool isLoading = false,
    String? apiError,
    VoidCallback? onPrivacyPolicyTap,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LeadForm(
            onSubmit: onSubmit ?? (_) async {},
            isLoading: isLoading,
            apiError: apiError,
            onPrivacyPolicyTap: onPrivacyPolicyTap ?? () {},
          ),
        ),
      ),
    );
  }

  // The submit button is disabled until the required consent checkbox is
  // ticked (independent of field validity), so tests that need to reach
  // validation or submission must tick it first. It's the first Checkbox
  // in the tree — the marketing opt-in checkbox is the second.
  Future<void> tickConsent(WidgetTester tester) async {
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
  }

  group('LeadForm validation', () {
    testWidgets('shows error when name is empty on submit', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      await tickConsent(tester);

      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(find.text('Please enter your full name.'), findsOneWidget);
    });

    testWidgets('shows error when name is too short', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      // Enter 1-char name
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'A');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(find.text('Name must be at least 2 characters.'), findsOneWidget);
    });

    testWidgets('shows error when email is empty after name filled',
        (tester) async {
      await tester.pumpWidget(buildLeadForm());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(find.text('Please enter your email address.'), findsOneWidget);
    });

    testWidgets('shows error when email format is invalid', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'not-an-email');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(
          find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('shows error when phone is empty', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(find.text('Please enter your mobile number.'), findsOneWidget);
    });

    testWidgets('shows error when phone is not 10 digits', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '1234');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(
          find.text('Please enter a 10-digit Australian mobile number.'),
          findsOneWidget);
    });

    testWidgets('shows error when phone has invalid prefix', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '1234567890');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(
          find.text(
              'Please enter a valid Australian phone number (e.g. 04XX XXX XXX).'),
          findsOneWidget);
    });

    testWidgets('shows error when postcode is empty', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '0412345678');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(find.text('Please enter your postcode.'), findsOneWidget);
    });

    testWidgets('shows error when postcode is not 4 digits', (tester) async {
      await tester.pumpWidget(buildLeadForm());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '0412345678');
      await tester.enterText(fields.at(3), '12');
      await tickConsent(tester);
      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(
          find.text('Please enter a valid 4-digit Australian postcode.'),
          findsOneWidget);
    });

    testWidgets('valid submission calls onSubmit callback', (tester) async {
      LeadFormData? capturedData;

      await tester.pumpWidget(buildLeadForm(
        onSubmit: (data) async {
          capturedData = data;
        },
      ));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '0412345678');
      await tester.enterText(fields.at(3), '2000');

      await tickConsent(tester);

      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(capturedData, isNotNull);
      expect(capturedData!.name, equals('John Doe'));
      expect(capturedData!.email, equals('john@example.com'));
      expect(capturedData!.phone, equals('0412345678'));
      expect(capturedData!.postcode, equals('2000'));
    });

    testWidgets('API error banner shown when apiError is non-null',
        (tester) async {
      await tester.pumpWidget(buildLeadForm(
        apiError:
            'Something went wrong. Please check your connection and try again.',
      ));

      expect(
        find.text(
            'Something went wrong. Please check your connection and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('loading state shows spinner instead of button label',
        (tester) async {
      await tester.pumpWidget(buildLeadForm(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('See My Recommendation'), findsNothing);
    });

    testWidgets('valid AU phone with 04 prefix passes validation',
        (tester) async {
      LeadFormData? capturedData;

      await tester.pumpWidget(buildLeadForm(
        onSubmit: (data) async {
          capturedData = data;
        },
      ));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Jane Smith');
      await tester.enterText(fields.at(1), 'jane@example.com');
      await tester.enterText(fields.at(2), '0498765432');
      await tester.enterText(fields.at(3), '3000');

      await tickConsent(tester);

      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(capturedData, isNotNull);
      expect(
          find.text('Please enter a 10-digit Australian mobile number.'),
          findsNothing);
    });
  });

  group('LeadForm consent', () {
    testWidgets('submit button is disabled until consent is ticked',
        (tester) async {
      bool submitted = false;
      await tester.pumpWidget(buildLeadForm(
        onSubmit: (_) async {
          submitted = true;
        },
      ));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '0412345678');
      await tester.enterText(fields.at(3), '2000');
      await tester.pump();

      final ElevatedButton buttonBefore =
          tester.widget(find.byType(ElevatedButton));
      expect(buttonBefore.onPressed, isNull);

      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();
      expect(submitted, isFalse);

      await tickConsent(tester);

      final ElevatedButton buttonAfter =
          tester.widget(find.byType(ElevatedButton));
      expect(buttonAfter.onPressed, isNotNull);

      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();
      expect(submitted, isTrue);
    });

    testWidgets('marketing opt-in defaults to false and is passed through',
        (tester) async {
      LeadFormData? capturedData;
      await tester.pumpWidget(buildLeadForm(
        onSubmit: (data) async {
          capturedData = data;
        },
      ));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), '0412345678');
      await tester.enterText(fields.at(3), '2000');
      await tickConsent(tester);

      await tester.tap(find.text('See My Recommendation'));
      await tester.pump();

      expect(capturedData!.marketingOptIn, isFalse);
    });

    testWidgets('tapping Privacy Policy link invokes callback',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
          buildLeadForm(onPrivacyPolicyTap: () => tapped = true));

      await tester.tap(find.text('Privacy Policy', findRichText: true));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
