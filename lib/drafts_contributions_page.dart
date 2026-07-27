import 'package:flutter/material.dart';
import 'solitude_explorer_theme.dart';

class DraftsContributionsPage extends StatefulWidget {
  const DraftsContributionsPage({super.key});

  @override
  State<DraftsContributionsPage> createState() =>
      _DraftsContributionsPageState();
}

class _DraftsContributionsPageState extends State<DraftsContributionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _drafts = [
    {
      'title': 'St. Fin Barre\'s Cathedral Review',
      'type': 'Review',
      'lastEdited': '2 hours ago',
      'progress': 0.8,
    },
    {
      'title': 'New Historical Route: Cork City Centre',
      'type': 'Route Edit',
      'lastEdited': 'Yesterday',
      'progress': 0.4,
    },
  ];

  final List<Map<String, dynamic>> _published = [
    {
      'title': 'Photo of Blarney Castle',
      'type': 'Photo Upload',
      'date': 'Oct 12, 2023',
      'likes': 14,
      'status': 'Approved',
    },
    {
      'title': 'Corrected location for English Market',
      'type': 'Map Edit',
      'date': 'Sep 28, 2023',
      'likes': 5,
      'status': 'Approved',
    },
    {
      'title': 'Review: University College Cork',
      'type': 'Review',
      'date': 'Sep 15, 2023',
      'likes': 2,
      'status': 'Pending Review',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: SolitudeExplorerTheme.inkBlack, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Contributions',
          style: TextStyle(
            color: SolitudeExplorerTheme.inkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: SolitudeExplorerTheme.burgundyRed,
          indicatorWeight: 3,
          labelColor: SolitudeExplorerTheme.inkBlack,
          unselectedLabelColor: SolitudeExplorerTheme.fadedInk,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Drafts'),
            Tab(text: 'Published'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDraftsTab(),
          _buildPublishedTab(),
        ],
      ),
    );
  }

  Widget _buildDraftsTab() {
    if (_drafts.isEmpty) {
      return _buildEmptyState('No drafts found.', Icons.edit_document);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'IN PROGRESS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SolitudeExplorerTheme.fadedInk,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _drafts.length; i++) ...[
                _buildDraftItem(_drafts[i]),
                if (i < _drafts.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDraftItem(Map<String, dynamic> draft) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    draft['title'],
                    style: const TextStyle(
                      color: SolitudeExplorerTheme.inkBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: SolitudeExplorerTheme.fadedInk,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.burgundyRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    draft['type'],
                    style: const TextStyle(
                      color: SolitudeExplorerTheme.burgundyRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Edited ${draft['lastEdited']}',
                  style: const TextStyle(
                    color: SolitudeExplorerTheme.fadedInk,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: draft['progress'],
                      minHeight: 4,
                      backgroundColor: SolitudeExplorerTheme.stainedPaperEdge,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(SolitudeExplorerTheme.burgundyRed),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(draft['progress'] * 100).toInt()}%',
                  style: const TextStyle(
                    color: SolitudeExplorerTheme.fadedInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishedTab() {
    if (_published.isEmpty) {
      return _buildEmptyState('No contributions yet.', Icons.public);
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'CONTRIBUTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: SolitudeExplorerTheme.fadedInk,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < _published.length; i++) ...[
                _buildPublishedItem(_published[i]),
                if (i < _published.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPublishedItem(Map<String, dynamic> item) {
    final isApproved = item['status'] == 'Approved';

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item['title'],
                    style: const TextStyle(
                      color: SolitudeExplorerTheme.inkBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  isApproved ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                  size: 18,
                  color: isApproved
                      ? SolitudeExplorerTheme.compassGold
                      : SolitudeExplorerTheme.burgundyRed.withOpacity(0.6),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.burgundyRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['type'],
                    style: const TextStyle(
                      color: SolitudeExplorerTheme.burgundyRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 14,
                  color: SolitudeExplorerTheme.fadedInk,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item['likes']}',
                  style: const TextStyle(
                    color: SolitudeExplorerTheme.fadedInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  item['date'],
                  style: const TextStyle(
                    color: SolitudeExplorerTheme.fadedInk,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: SolitudeExplorerTheme.stainedPaperEdge),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: SolitudeExplorerTheme.fadedInk,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
