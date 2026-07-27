import 'package:flutter/material.dart';
import 'solitude_explorer_theme.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        title: const Text('Language'),
      ),
      body: const Center(
        child: Text('Language Settings Page'),
      ),
    );
  }
}
