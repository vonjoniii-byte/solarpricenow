// main.dart — app entry point.
// Sets up MultiProvider (FunnelController) and launches SolarCalculatorApp.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/funnel_controller.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FunnelController>(
          create: (_) => FunnelController(),
        ),
      ],
      child: const SolarCalculatorApp(),
    ),
  );
}
