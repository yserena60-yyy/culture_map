import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'solitude_explorer_theme.dart';

class CommentsPage extends StatefulWidget {
  final String placeName;
  final String? placeId;
  final String? wikidataEntityId;

  const CommentsPage({
    super.key,
    required this.placeName,
    this.placeId,
    this.wikidataEntityId,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

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

      if (identifier == null || idColumn == null) {
        if (mounted) {
          setState(() {
            _comments = [];
            _isLoading = false;
          });
        }
        return;
      }

      final response = await Supabase.instance.client
          .from('comments')
          .select()
          .eq(idColumn, identifier)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _comments = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
      if (mounted) {
        setState(() {
          _comments = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SolitudeExplorerTheme.inkBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Comments',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: SolitudeExplorerTheme.inkBlack,
          ),
        ),
      ),
      body: Column(
        children: [
          // Place name header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SolitudeExplorerTheme.stainedPaper,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.placeName,
                  style: GoogleFonts.crimsonText(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: SolitudeExplorerTheme.inkBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_comments.length} ${_comments.length == 1 ? 'comment' : 'comments'}',
                  style: GoogleFonts.crimsonText(
                    fontSize: 14,
                    color: SolitudeExplorerTheme.fadedInk,
                  ),
                ),
              ],
            ),
          ),

          // Comments list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(
                    color: SolitudeExplorerTheme.compassGold,
                  ))
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              size: 64,
                              color: SolitudeExplorerTheme.fadedInk.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: GoogleFonts.crimsonText(
                                fontSize: 18,
                                color: SolitudeExplorerTheme.fadedInk,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) => _buildCommentCard(_comments[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final rating = comment['rating'] as int?;
    final content = comment['content'] as String? ?? '';
    final createdAt = DateTime.parse(comment['created_at']);
    final formattedDate = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rating != null) ...[
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 18,
                      color: SolitudeExplorerTheme.compassGold,
                    ),
                  ),
                ),
                const Spacer(),
              ],
              Text(
                formattedDate,
                style: GoogleFonts.crimsonText(
                  fontSize: 13,
                  color: SolitudeExplorerTheme.fadedInk,
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: GoogleFonts.crimsonText(
                fontSize: 15,
                color: SolitudeExplorerTheme.inkBlack,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
