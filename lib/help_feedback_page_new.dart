import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'solitude_explorer_theme.dart';

class HelpFeedbackPageNew extends StatefulWidget {
  const HelpFeedbackPageNew({super.key});

  @override
  State<HelpFeedbackPageNew> createState() => _HelpFeedbackPageNewState();
}

class _HelpFeedbackPageNewState extends State<HelpFeedbackPageNew> {
  final TextEditingController _feedbackController = TextEditingController();
  String? _expandedFaq;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I add a new landmark?',
      'answer':
          'Tap the + button on the map page, then select a location and fill in the details about the landmark.',
    },
    {
      'question': 'How is my Explorer Level calculated?',
      'answer':
          'Your level is based on XP earned from check-ins, reviews, and stories. Each check-in gives 10 XP, each review 5 XP, and each story 20 XP.',
    },
    {
      'question': 'Can I download maps for offline use?',
      'answer':
          'Yes! Go to Profile → Offline Maps, then select the regions you want to download. Maps will be available even without internet.',
    },
    {
      'question': 'How do I edit my profile?',
      'answer':
          'Tap your profile avatar on the Profile page, then tap the edit icon to change your photo, name, and bio.',
    },
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        title: Text(
          'HELP & FEEDBACK',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            ..._faqs.map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.stainedPaper,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: SolitudeExplorerTheme.inkBlack,
                        ),
                      ),
                      trailing: Icon(
                        _expandedFaq == faq['question']
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: SolitudeExplorerTheme.fadedInk,
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedFaq = expanded ? faq['question'] : null;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['answer']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: SolitudeExplorerTheme.fadedInk,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 32),

            // Contact Support Section
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SolitudeExplorerTheme.inkBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Have an issue or a suggestion? Let us know!',
              style: TextStyle(
                fontSize: 14,
                color: SolitudeExplorerTheme.fadedInk,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.stainedPaper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _feedbackController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Describe your issue or feedback here...',
                      hintStyle: TextStyle(
                        color: SolitudeExplorerTheme.fadedInk,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: SolitudeExplorerTheme.stainedPaperEdge,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: SolitudeExplorerTheme.stainedPaperEdge,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: SolitudeExplorerTheme.burgundyRed,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _feedbackController.text.trim().isNotEmpty
                        ? () {
                            // Submit feedback
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: SolitudeExplorerTheme.stainedPaper,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text('Thank You!'),
                                content: const Text(
                                  'Your feedback has been submitted. We\'ll get back to you soon.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _feedbackController.clear();
                                      setState(() {});
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5A3F),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
