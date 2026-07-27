import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'solitude_explorer_theme.dart';
import 'navigation_page.dart';

class SavedPlacesPage extends StatefulWidget {
  const SavedPlacesPage({super.key});

  @override
  State<SavedPlacesPage> createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _savedPlaces = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPlaces();
  }

  Future<void> _loadSavedPlaces() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load user's bookmarked places
      final response = await Supabase.instance.client
          .from('bookmarks')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _savedPlaces = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved places: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeBookmark(String bookmarkId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SolitudeExplorerTheme.stainedPaper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: SolitudeExplorerTheme.stainedPaperEdge,
            width: 2,
          ),
        ),
        title: Text(
          'Remove Bookmark?',
          style: GoogleFonts.crimsonText(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: SolitudeExplorerTheme.inkBlack,
          ),
        ),
        content: Text(
          'Do you want to remove this place from your saved places?',
          style: GoogleFonts.crimsonText(
            fontSize: 16,
            color: SolitudeExplorerTheme.fadedInk,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                color: SolitudeExplorerTheme.fadedInk,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Remove',
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: SolitudeExplorerTheme.burgundyRed,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await Supabase.instance.client
          .from('bookmarks')
          .delete()
          .eq('id', bookmarkId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bookmark removed',
              style: GoogleFonts.crimsonText(fontSize: 15),
            ),
          ),
        );
        _loadSavedPlaces();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.crimsonText(fontSize: 15),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.stainedPaper,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SolitudeExplorerTheme.inkBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Places & Routes',
          style: GoogleFonts.crimsonText(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: SolitudeExplorerTheme.inkBlack,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SolitudeExplorerTheme.burgundyRed,
              ),
            )
          : _savedPlaces.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedPlaces.length,
                  itemBuilder: (context, index) {
                    final bookmark = _savedPlaces[index];
                    return _buildPlaceCard(bookmark);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 80,
            color: SolitudeExplorerTheme.fadedInk.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved places yet',
            style: GoogleFonts.crimsonText(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: SolitudeExplorerTheme.inkBlack,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Bookmark landmarks to save them for later',
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                fontSize: 15,
                color: SolitudeExplorerTheme.fadedInk,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> bookmark) {
    final bookmarkId = bookmark['id'] as String;
    final placeName = bookmark['place_name'] as String? ?? 'Unknown Place';
    final category = bookmark['place_category'] as String? ?? '';
    final year = bookmark['place_year'] as int?;
    final imageUrl = bookmark['place_image_url'] as String?;
    final description = bookmark['place_description'] as String?;
    final lat = bookmark['place_lat'] as double?;
    final lng = bookmark['place_lng'] as double?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        placeName,
                        style: GoogleFonts.crimsonText(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: SolitudeExplorerTheme.inkBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark,
                        color: SolitudeExplorerTheme.burgundyRed,
                      ),
                      onPressed: () => _removeBookmark(bookmarkId),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.apartment,
                                size: 14, color: SolitudeExplorerTheme.fadedInk),
                            const SizedBox(width: 6),
                            Text(
                              category,
                              style: GoogleFonts.crimsonText(
                                fontSize: 12,
                                color: SolitudeExplorerTheme.inkBlack,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (year != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: SolitudeExplorerTheme.compassGold),
                            const SizedBox(width: 6),
                            Text(
                              _formatYear(year),
                              style: GoogleFonts.crimsonText(
                                fontSize: 12,
                                color: SolitudeExplorerTheme.compassGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      description,
                      style: GoogleFonts.crimsonText(
                        fontSize: 14,
                        color: SolitudeExplorerTheme.fadedInk,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (lat != null && lng != null)
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavigationPage(
                                  destinationName: placeName,
                                  destinationLat: lat,
                                  destinationLng: lng,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SolitudeExplorerTheme.burgundyRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.navigation, size: 16),
                    label: Text(
                      'Navigate',
                      style: GoogleFonts.crimsonText(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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
