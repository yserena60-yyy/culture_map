import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'solitude_explorer_theme.dart';
import 'navigation_page.dart';
import 'comments_page.dart';

class LandmarkPreviewCard extends StatefulWidget {
  final String name;
  final String category;
  final int builtYear;
  final String? imageUrl;
  final String? description;
  final String? wikipediaUrl;
  final String? wikidataEntityId;
  final String? placeId;
  final double? latitude;
  final double? longitude;
  final VoidCallback onTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onNavigateTap;

  const LandmarkPreviewCard({
    super.key,
    required this.name,
    required this.category,
    required this.builtYear,
    this.imageUrl,
    this.description,
    this.wikipediaUrl,
    this.wikidataEntityId,
    this.placeId,
    this.latitude,
    this.longitude,
    required this.onTap,
    this.onCommentTap,
    this.onNavigateTap,
  });

  @override
  State<LandmarkPreviewCard> createState() => _LandmarkPreviewCardState();
}

class _LandmarkPreviewCardState extends State<LandmarkPreviewCard> {
  bool _isBookmarked = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _recentComments = [];
  int _totalComments = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('LandmarkPreviewCard: ${widget.name}');
    debugPrint('  placeId: ${widget.placeId}');
    debugPrint('  wikidataEntityId: ${widget.wikidataEntityId}');
    _checkBookmarkStatus();
    _loadRecentComments();
  }

  Future<void> _checkBookmarkStatus() async {
    final identifier = widget.placeId ?? widget.wikidataEntityId;
    if (identifier == null) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final idColumn = widget.placeId != null ? 'place_id' : 'wikidata_entity_id';

      final response = await Supabase.instance.client
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq(idColumn, identifier)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isBookmarked = response != null;
        });
      }
    } catch (e) {
      debugPrint('Error checking bookmark: $e');
    }
  }

  Future<void> _loadRecentComments() async {
    try {
      String? identifier;
      String? idColumn;

      if (widget.placeId != null) {
        identifier = widget.placeId;
        idColumn = 'place_id';
      } else if (widget.wikidataEntityId != null) {
        identifier = widget.wikidataEntityId;
        idColumn = 'wikidata_entity_id';
      }

      debugPrint('Loading comments for: $idColumn = $identifier');

      if (identifier == null || idColumn == null) {
        debugPrint('No identifier found, skipping comment load');
        return;
      }

      final response = await Supabase.instance.client
          .from('comments')
          .select()
          .eq(idColumn, identifier)
          .order('created_at', ascending: false)
          .limit(3);

      debugPrint('Comments loaded: ${response.length} comments found');

      if (mounted) {
        setState(() {
          _recentComments = List<Map<String, dynamic>>.from(response);
          _totalComments = _recentComments.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    final identifier = widget.placeId ?? widget.wikidataEntityId;
    if (identifier == null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to bookmark places')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final idColumn = widget.placeId != null ? 'place_id' : 'wikidata_entity_id';

      if (_isBookmarked) {
        // Remove bookmark
        await Supabase.instance.client
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq(idColumn, identifier);

        if (mounted) {
          setState(() => _isBookmarked = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark removed')),
          );
        }
      } else {
        // Add bookmark with full place data
        final bookmarkData = {
          'user_id': userId,
          'place_name': widget.name,
          'place_category': widget.category,
          'place_year': widget.builtYear,
          'place_image_url': widget.imageUrl,
          'place_description': widget.description,
          'place_wikipedia_url': widget.wikipediaUrl,
          'place_lat': widget.latitude,
          'place_lng': widget.longitude,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Add the appropriate identifier field
        if (widget.placeId != null) {
          bookmarkData['place_id'] = widget.placeId!;
        } else {
          bookmarkData['wikidata_entity_id'] = widget.wikidataEntityId!;
        }

        await Supabase.instance.client.from('bookmarks').insert(bookmarkData);

        if (mounted) {
          setState(() => _isBookmarked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark saved')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToLocation() {
    if (widget.latitude != null && widget.longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NavigationPage(
            destinationName: widget.name,
            destinationLat: widget.latitude!,
            destinationLng: widget.longitude!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(), // Hide completely if image fails to load
              ),
            ),
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            const SizedBox(height: 20),

          // Title and bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.name,
                  style: GoogleFonts.crimsonText(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: SolitudeExplorerTheme.inkBlack,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isLoading ? null : _toggleBookmark,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isBookmarked ? SolitudeExplorerTheme.burgundyRed : Colors.transparent,
                    border: Border.all(
                      color: SolitudeExplorerTheme.inkBlack,
                      width: 2,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(SolitudeExplorerTheme.inkBlack),
                          ),
                        )
                      : Icon(
                          _isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          size: 22,
                          color: _isBookmarked ? Colors.white : SolitudeExplorerTheme.inkBlack,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category and year badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.apartment,
                        size: 15, color: SolitudeExplorerTheme.fadedInk),
                    const SizedBox(width: 7),
                    Text(
                      widget.category,
                      style: GoogleFonts.crimsonText(
                        fontSize: 13,
                        color: SolitudeExplorerTheme.inkBlack,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 15, color: SolitudeExplorerTheme.compassGold),
                    const SizedBox(width: 7),
                    Text(
                      _formatYear(widget.builtYear),
                      style: GoogleFonts.crimsonText(
                        fontSize: 13,
                        color: SolitudeExplorerTheme.compassGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (widget.description != null && widget.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.description!,
                style: GoogleFonts.crimsonText(
                  fontSize: 14,
                  color: SolitudeExplorerTheme.fadedInk,
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // Comments preview section
          if (_recentComments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.rate_review,
                        size: 16,
                        color: SolitudeExplorerTheme.compassGold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recent Comments ($_totalComments)',
                        style: GoogleFonts.crimsonText(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: SolitudeExplorerTheme.inkBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _recentComments.length > 2 ? 2 : _recentComments.length,
                    (index) {
                      final comment = _recentComments[index];
                      final rating = comment['rating'] as int?;
                      final content = comment['content'] as String? ?? '';

                      return Padding(
                        padding: EdgeInsets.only(bottom: index < 1 && _recentComments.length > 1 ? 10 : 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (rating != null)
                              Row(
                                children: List.generate(
                                  rating,
                                  (i) => const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: SolitudeExplorerTheme.compassGold,
                                  ),
                                ),
                              ),
                            if (rating != null) const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                content.isEmpty ? 'No comment text' : content,
                                style: GoogleFonts.crimsonText(
                                  fontSize: 12,
                                  color: SolitudeExplorerTheme.fadedInk,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (_totalComments > 2) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentsPage(
                              placeName: widget.name,
                              placeId: widget.placeId,
                              wikidataEntityId: widget.wikidataEntityId,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View all comments',
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SolitudeExplorerTheme.compassGold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Wikipedia button (top, outlined)
          if (widget.wikipediaUrl != null && widget.wikipediaUrl!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(widget.wikipediaUrl!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: SolitudeExplorerTheme.burgundyRed,
                  side: const BorderSide(
                    color: SolitudeExplorerTheme.burgundyRed,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(
                  'View on Wikipedia',
                  style: GoogleFonts.crimsonText(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (widget.wikipediaUrl != null && widget.wikipediaUrl!.isNotEmpty)
            const SizedBox(height: 12),

          // Comment Button (middle, full width, gold background)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onCommentTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: SolitudeExplorerTheme.compassGold,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.comment, size: 14, color: Colors.white),
              ),
              label: Text(
                'Comment',
                style: GoogleFonts.crimsonText(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Navigate button (bottom, burgundy background)
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: SolitudeExplorerTheme.burgundyRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.navigation, size: 14, color: Colors.white),
              ),
              label: Text(
                'Navigate',
                style: GoogleFonts.crimsonText(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatYear(int year) {
    return year < 0 ? '${-year} BC' : 'AD $year';
  }
}
