import 'package:flutter/material.dart';
import '../shared/transparency_screen.dart';

class ChildConsentScreen extends StatelessWidget {
  const ChildConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransparencyScreen(audience: TransparencyAudience.child);
  }
}
