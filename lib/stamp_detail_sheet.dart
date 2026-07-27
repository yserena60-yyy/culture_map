import 'package:flutter/material.dart';
import 'solitude_explorer_theme.dart';
import 'models.dart';

class StampDetailSheet extends StatelessWidget {
  final Stamp stamp;
  final dynamic supabaseService;
  final VoidCallback? onUnlockSuccess;

  const StampDetailSheet({
    super.key,
    required this.stamp,
    this.supabaseService,
    this.onUnlockSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SolitudeExplorerTheme.stainedPaperEdge,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            stamp.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SolitudeExplorerTheme.inkBlack,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: SolitudeExplorerTheme.fadedInk),
              const SizedBox(width: 8),
              Text(
                stamp.region,
                style: const TextStyle(
                  fontSize: 14,
                  color: SolitudeExplorerTheme.fadedInk,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
