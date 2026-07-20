diff --git a/lib/screens/results_screen.dart b/lib/screens/results_screen.dart
index f9fc62c..1b78553 100644
--- a/lib/screens/results_screen.dart
+++ b/lib/screens/results_screen.dart
@@ -33,6 +33,7 @@ class ResultsScreen extends StatefulWidget {
 class _ResultsScreenState extends State<ResultsScreen> {
   bool _financeDetailsRevealed = false;
   bool _estimateDetailsRevealed = false;
+  bool _billReductionDetailsRevealed = false;
 
   @override
   void initState() {
@@ -276,15 +277,16 @@ class _ResultsScreenState extends State<ResultsScreen> {
           Divider(height: 1, color: AppColors.line),
           if (priced != null) ...[
             const SizedBox(height: 4),
-            _metricsBlock(priced, reduction, finance),
+            _metricsBlock(
+                priced, reduction, finance, controller.input?.bill2month),
           ],
         ],
       ),
     );
   }
 
-  Widget _metricsBlock(
-      PricedResult priced, int? reduction, FinanceResult? finance) {
+  Widget _metricsBlock(PricedResult priced, int? reduction,
+      FinanceResult? finance, double? billBefore) {
     return Column(
       children: [
         InkWell(
@@ -293,6 +295,7 @@ class _ResultsScreenState extends State<ResultsScreen> {
           child: _metricRow(
             icon: Icons.savings_rounded,
             label: 'Investment',
+            labelCaption: 'After state & federal rebates',
             value: _money(priced.price),
             trailingBadge: Column(
               crossAxisAlignment: CrossAxisAlignment.end,
@@ -322,6 +325,35 @@ class _ResultsScreenState extends State<ResultsScreen> {
                 )
               : const SizedBox(width: double.infinity),
         ),
+        if (reduction != null) ...[
+          _rowDivider(),
+          InkWell(
+            onTap: () => setState(() => _billReductionDetailsRevealed =
+                !_billReductionDetailsRevealed),
+            child: _metricRow(
+              icon: Icons.trending_down_rounded,
+              label: 'Bill reduction',
+              value: '$reduction%',
+              trailingBadge: Icon(
+                _billReductionDetailsRevealed
+                    ? Icons.expand_less_rounded
+                    : Icons.expand_more_rounded,
+                size: 16,
+                color: AppColors.textMuted,
+              ),
+            ),
+          ),
+          AnimatedSize(
+            duration: const Duration(milliseconds: 200),
+            alignment: Alignment.topCenter,
+            child: _billReductionDetailsRevealed
+                ? Padding(
+                    padding: const EdgeInsets.only(bottom: 8),
+                    child: _billReductionDetail(billBefore, priced),
+                  )
+                : const SizedBox(width: double.infinity),
+          ),
+        ],
         _rowDivider(),
         _metricRow(
           icon: Icons.trending_up_rounded,
@@ -334,14 +366,6 @@ class _ResultsScreenState extends State<ResultsScreen> {
           label: 'Payback',
           value: '${priced.paybackYears.toStringAsFixed(1)} years',
         ),
-        if (reduction != null) ...[
-          _rowDivider(),
-          _metricRow(
-            icon: Icons.trending_down_rounded,
-            label: 'Bill reduction',
-            value: '$reduction%',
-          ),
-        ],
         _rowDivider(),
         InkWell(
           onTap: finance != null
@@ -399,9 +423,75 @@ class _ResultsScreenState extends State<ResultsScreen> {
     );
   }
 
+  // Bill reduction detail — average bimonthly bill before vs. after solar.
+  Widget _billReductionDetail(double? billBefore, PricedResult priced) {
+    if (billBefore == null || billBefore <= 0) {
+      return _estimateCaveatRow(
+        'Average bill amounts aren\'t available for this estimate.',
+      );
+    }
+    return Column(
+      crossAxisAlignment: CrossAxisAlignment.start,
+      children: [
+        Row(
+          children: [
+            Expanded(
+              child: _billAmountTile(
+                label: 'Before solar',
+                value: _money(billBefore),
+              ),
+            ),
+            const SizedBox(width: 10),
+            Icon(Icons.arrow_forward_rounded,
+                size: 16, color: AppColors.textMuted),
+            const SizedBox(width: 10),
+            Expanded(
+              child: _billAmountTile(
+                label: 'After solar',
+                value: _money(priced.estBillAfter2mo),
+              ),
+            ),
+          ],
+        ),
+        const SizedBox(height: 8),
+        _estimateCaveatRow(
+          'Average bill amounts are indicative, based on a typical 2-month '
+          'billing cycle.',
+        ),
+      ],
+    );
+  }
+
+  Widget _billAmountTile({required String label, required String value}) {
+    return Column(
+      crossAxisAlignment: CrossAxisAlignment.start,
+      children: [
+        Text(label,
+            style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
+        const SizedBox(height: 2),
+        Text(value, style: AppTypography.bodySemibold.copyWith(fontSize: 16)),
+      ],
+    );
+  }
+
+  Widget _estimateCaveatRow(String text) {
+    return Row(
+      crossAxisAlignment: CrossAxisAlignment.start,
+      children: [
+        const Icon(Icons.info_outline_rounded,
+            size: 16, color: AppColors.textMuted),
+        const SizedBox(width: 6),
+        Expanded(
+          child: Text(text, style: AppTypography.caption.copyWith(height: 1.5)),
+        ),
+      ],
+    );
+  }
+
   Widget _metricRow({
     required IconData icon,
     required String label,
+    String? labelCaption,
     required String value,
     Widget? trailingBadge,
   }) {
@@ -413,9 +503,27 @@ class _ResultsScreenState extends State<ResultsScreen> {
           Icon(icon, size: 18, color: AppColors.textSecondary),
           const SizedBox(width: 10),
           Expanded(
-            child: Text(
-              label,
-              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
+            child: Column(
+              crossAxisAlignment: CrossAxisAlignment.start,
+              children: [
+                Text(
+                  label,
+                  style: AppTypography.body
+                      .copyWith(color: AppColors.textSecondary),
+                ),
+                if (labelCaption != null)
+                  Padding(
+                    padding: const EdgeInsets.only(top: 2),
+                    child: Text(
+                      labelCaption,
+                      style: AppTypography.caption.copyWith(
+                        color: AppColors.textMuted,
+                        fontSize: 11,
+                        height: 1.2,
+                      ),
+                    ),
+                  ),
+              ],
             ),
           ),
           Column(