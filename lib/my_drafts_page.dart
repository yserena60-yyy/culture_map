import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'solitude_explorer_theme.dart';

class MyDraftsPage extends StatefulWidget {
  const MyDraftsPage({super.key});

  @override
  State<MyDraftsPage> createState() => _MyDraftsPageState();
}

class _MyDraftsPageState extends State<MyDraftsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _contributions = [];

  @override
  void initState() {
    super.initState();
    _loadContributions();
  }

  Future<void> _loadContributions() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load user's comments as contributions
      final response = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _contributions = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading contributions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
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
          'My Drafts & Contributions',
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
          : _contributions.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _contributions.length,
                  itemBuilder: (context, index) {
                    final contribution = _contributions[index];
                    return _buildContributionCard(contribution);
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
            Icons.edit_document,
            size: 80,
            color: SolitudeExplorerTheme.fadedInk.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No contributions yet',
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
              'Share your knowledge by adding comments to landmarks',
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

  Widget _buildContributionCard(Map<String, dynamic> contribution) {
    final commentId = contribution['id'] as String;
    final placeName = contribution['place_name'] as String? ?? 'Unknown Place';
    final comment = contribution['content'] ?? '';
    final rating = contribution['rating'] as int?;
    final createdAt = DateTime.parse(contribution['created_at']);
    final formattedDate = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SolitudeExplorerTheme.burgundyRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.comment,
                  size: 20,
                  color: SolitudeExplorerTheme.burgundyRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeName,
                      style: GoogleFonts.crimsonText(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: SolitudeExplorerTheme.inkBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          formattedDate,
                          style: GoogleFonts.crimsonText(
                            fontSize: 13,
                            color: SolitudeExplorerTheme.fadedInk,
                          ),
                        ),
                        if (rating != null) ...[
                          const SizedBox(width: 12),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                size: 14,
                                color: SolitudeExplorerTheme.compassGold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: SolitudeExplorerTheme.burgundyRed,
                ),
                onPressed: () => _deleteComment(commentId),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                comment,
                style: GoogleFonts.crimsonText(
                  fontSize: 14,
                  color: SolitudeExplorerTheme.inkBlack,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await Supabase.instance.client
          .from('comments')
          .delete()
          .eq('id', commentId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted')),
        );
        _loadContributions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
