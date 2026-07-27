import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'solitude_explorer_theme.dart';
import 'main.dart' show TimelineAnchor;

class LandmarkDetailPage extends StatelessWidget {
  final String? placeId;
  final String? wikidataEntityId;
  final String name;
  final String category;
  final int builtYear;
  final String? wikipediaUrl;
  final double lat;
  final double lng;
  final List<TimelineAnchor> timelineAnchors;
  final LatLng? currentLocation;

  const LandmarkDetailPage({
    super.key,
    this.placeId,
    this.wikidataEntityId,
    required this.name,
    required this.category,
    required this.builtYear,
    this.wikipediaUrl,
    required this.lat,
    required this.lng,
    this.timelineAnchors = const [],
    this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.stainedPaper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.category_outlined,
                          size: 16, color: SolitudeExplorerTheme.fadedInk),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SolitudeExplorerTheme.fadedInk,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.calendar_today_outlined,
                          size: 16, color: SolitudeExplorerTheme.fadedInk),
                      const SizedBox(width: 8),
                      Text(
                        _formatYear(builtYear),
                        style: const TextStyle(
                          fontSize: 14,
                          color: SolitudeExplorerTheme.fadedInk,
                        ),
                      ),
                    ],
                  ),
                  if (wikipediaUrl != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('View on Wikipedia'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SolitudeExplorerTheme.burgundyRed,
                        side: const BorderSide(
                            color: SolitudeExplorerTheme.burgundyRed),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline section
            if (timelineAnchors.isNotEmpty) ...[
              const Text(
                'Historical Timeline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: SolitudeExplorerTheme.inkBlack,
                ),
              ),
              const SizedBox(height: 12),
              ...timelineAnchors.map((anchor) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SolitudeExplorerTheme.stainedPaper,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: SolitudeExplorerTheme.stainedPaperEdge),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: SolitudeExplorerTheme.burgundyRed
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            anchor.year.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: SolitudeExplorerTheme.burgundyRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anchor.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: SolitudeExplorerTheme.inkBlack,
                                ),
                              ),
                              if (anchor.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  anchor.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: SolitudeExplorerTheme.fadedInk,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // Comments section
            const Text(
              'Comments & Stories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SolitudeExplorerTheme.inkBlack,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.stainedPaper,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              ),
              child: Column(
                children: [
                  const Text(
                    'Share your experience or historical insights about this landmark.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: SolitudeExplorerTheme.fadedInk,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_comment_outlined, size: 18),
                    label: const Text('Add Comment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SolitudeExplorerTheme.burgundyRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for comments list
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.stainedPaper.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: SolitudeExplorerTheme.stainedPaperEdge,
                    style: BorderStyle.solid,
                    width: 1),
              ),
              child: const Center(
                child: Text(
                  'No comments yet. Be the first to share!',
                  style: TextStyle(
                    fontSize: 14,
                    color: SolitudeExplorerTheme.fadedInk,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatYear(int year) {
    return year < 0 ? '${-year} BC' : 'AD $year';
  }
}
