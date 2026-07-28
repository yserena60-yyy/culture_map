import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'solitude_explorer_theme.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  static const _options = <_LanguageOption>[
    _LanguageOption(locale: null, label: 'System Default', subtitle: 'Follow device language'),
    _LanguageOption(locale: Locale('en'), label: 'English', subtitle: 'English'),
    _LanguageOption(locale: Locale('zh'), label: '中文', subtitle: 'Simplified Chinese'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        elevation: 0,
        title: Text(s.switchLanguage),
      ),
      body: ValueListenableBuilder<Locale?>(
        valueListenable: localeController,
        builder: (context, currentLocale, _) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: _options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = _options[index];
              final isSelected = option.locale?.languageCode == currentLocale?.languageCode;
              return InkWell(
                onTap: () => localeController.setLocale(option.locale),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? SolitudeExplorerTheme.burgundyRed
                          : SolitudeExplorerTheme.stainedPaperEdge,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: SolitudeExplorerTheme.inkBlack,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              option.subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: SolitudeExplorerTheme.fadedInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: SolitudeExplorerTheme.burgundyRed, size: 22)
                      else
                        const Icon(Icons.circle_outlined,
                            color: SolitudeExplorerTheme.stainedPaperEdge, size: 22),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LanguageOption {
  final Locale? locale;
  final String label;
  final String subtitle;

  const _LanguageOption({required this.locale, required this.label, required this.subtitle});
}
