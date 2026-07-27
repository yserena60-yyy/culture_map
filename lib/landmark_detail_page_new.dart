import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'solitude_explorer_theme.dart';
import 'main.dart' show TimelineAnchor;

class LandmarkDetailPageNew extends StatefulWidget {
  final String? placeId;
  final String? wikidataEntityId;
  final String name;
  final String category;
  final int builtYear;
  final String? wikipediaUrl;
  final String? description;
  final String? imageUrl;
  final double lat;
  final double lng;
  final List<TimelineAnchor> timelineAnchors;
  final LatLng? currentLocation;

  const LandmarkDetailPageNew({
    super.key,
    this.placeId,
    this.wikidataEntityId,
    required this.name,
    required this.category,
    required this.builtYear,
    this.wikipediaUrl,
    this.description,
    this.imageUrl,
    required this.lat,
    required this.lng,
    this.timelineAnchors = const [],
    this.currentLocation,
  });

  @override
  State<LandmarkDetailPageNew> createState() => _LandmarkDetailPageNewState();
}

class _LandmarkDetailPageNewState extends State<LandmarkDetailPageNew> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a rating')),
      );
      return;
    }

    // Use either placeId or wikidataEntityId as identifier
    final identifier = widget.placeId ?? widget.wikidataEntityId;
    if (identifier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to submit rating: location identifier not found')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Insert comment into Supabase
      final commentData = <String, dynamic>{
        'user_id': user.id,
        'content': _commentController.text.trim(),
        'rating': _selectedRating,
        'place_name': widget.name, // Save place name
        'created_at': DateTime.now().toIso8601String(),
      };

      // Add the appropriate identifier field
      if (widget.placeId != null) {
        commentData['place_id'] = widget.placeId!;
      } else {
        commentData['wikidata_entity_id'] = widget.wikidataEntityId!;
      }

      await Supabase.instance.client.from('comments').insert(commentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully!')),
        );
        setState(() {
          _selectedRating = 0;
          _commentController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatYear(int year) {
    return year < 0 ? '${-year} BC' : 'AD $year';
  }

  double _calculateDistance() {
    if (widget.currentLocation == null) return 0;
    const distance = Distance();
    return distance.as(
      LengthUnit.Meter,
      widget.currentLocation!,
      LatLng(widget.lat, widget.lng),
    );
  }

  bool _isWithinCheckInRange() {
    final dist = _calculateDistance();
    return dist <= 500; // 500m
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E2E), // Dark green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E2E),
        foregroundColor: SolitudeExplorerTheme.agedYellow,
        elevation: 0,
        actions: [
          if (widget.wikipediaUrl != null)
            TextButton.icon(
              onPressed: () async {
                final url = Uri.parse(widget.wikipediaUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Wikipedia'),
              style: TextButton.styleFrom(
                foregroundColor: SolitudeExplorerTheme.agedYellow,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with dark background
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2C3E2E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.category_outlined,
                                size: 14, color: SolitudeExplorerTheme.agedYellow),
                            const SizedBox(width: 4),
                            Text(
                              widget.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: SolitudeExplorerTheme.agedYellow,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: SolitudeExplorerTheme.agedYellow),
                            const SizedBox(width: 4),
                            Text(
                              _formatYear(widget.builtYear),
                              style: TextStyle(
                                fontSize: 12,
                                color: SolitudeExplorerTheme.agedYellow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: SolitudeExplorerTheme.agedYellow,
                    ),
                  ),
                ],
              ),
            ),

            // Stats section
            Container(
              color: SolitudeExplorerTheme.agedYellow,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatItem(Icons.people_outline, '0', 'Check-ins'),
                  Container(height: 40, width: 1, color: SolitudeExplorerTheme.stainedPaperEdge),
                  _buildStatItem(Icons.star_outline, '—', '0 ratings'),
                  Container(height: 40, width: 1, color: SolitudeExplorerTheme.stainedPaperEdge),
                  _buildStatItem(Icons.menu_book_outlined, '0', 'Stories'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Check-in section
            Container(
              color: SolitudeExplorerTheme.agedYellow,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: SolitudeExplorerTheme.compassGold),
                      const SizedBox(width: 8),
                      const Text(
                        'Check-in',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SolitudeExplorerTheme.stainedPaper,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.my_location,
                              color: SolitudeExplorerTheme.compassGold, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check in on site',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Must be within 500m',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: SolitudeExplorerTheme.fadedInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isWithinCheckInRange() ? () {} : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SolitudeExplorerTheme.compassGold,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Check-in'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Rating & Review section
            Container(
              color: SolitudeExplorerTheme.agedYellow,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_outline, size: 20, color: SolitudeExplorerTheme.compassGold),
                      const SizedBox(width: 8),
                      const Text(
                        'Rating & Review',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Rating',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setState(() => _selectedRating = index + 1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  index < _selectedRating ? Icons.star : Icons.star_outline,
                                  size: 36,
                                  color: index < _selectedRating
                                      ? SolitudeExplorerTheme.compassGold
                                      : Colors.grey.shade400,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Leave a comment (optional)',
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
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_selectedRating > 0 && !_isSubmitting) ? _submitRating : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SolitudeExplorerTheme.compassGold,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Submit Rating',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Traveler Stories section
            Container(
              color: SolitudeExplorerTheme.agedYellow,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_outlined, size: 20, color: SolitudeExplorerTheme.compassGold),
                      const SizedBox(width: 8),
                      const Text(
                        'Traveler Stories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Write Your Story',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _storyController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Record your encounter with this place...',
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
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.send_outlined, size: 18),
                            label: const Text('Publish'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SolitudeExplorerTheme.compassGold,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No stories yet. Be the first to share.',
                      style: TextStyle(
                        fontSize: 14,
                        color: SolitudeExplorerTheme.fadedInk,
                        fontStyle: FontStyle.italic,
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: SolitudeExplorerTheme.compassGold),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SolitudeExplorerTheme.inkBlack,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: SolitudeExplorerTheme.fadedInk,
            ),
          ),
        ],
      ),
    );
  }
}
