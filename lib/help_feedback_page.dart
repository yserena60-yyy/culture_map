import 'package:flutter/material.dart';
import 'solitude_explorer_theme.dart';

class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        title: const Text('Help & Feedback'),
      ),
      body: const Center(
        child: Text('Help & Feedback Page'),
      ),
    );
  }
}
