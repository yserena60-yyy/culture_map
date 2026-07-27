import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'solitude_explorer_theme.dart';

class OfflineMapsPageNew extends StatefulWidget {
  const OfflineMapsPageNew({super.key});

  @override
  State<OfflineMapsPageNew> createState() => _OfflineMapsPageNewState();
}

class _OfflineMapsPageNewState extends State<OfflineMapsPageNew> {
  static const Color _deepGreen = Color(0xFF3D5A3F); // Unified green color

  final List<MapRegion> _regions = [
    MapRegion(
      name: 'Kyoto City (Full)',
      size: '245 MB',
      isDownloaded: true,
      downloadProgress: 1.0,
    ),
    MapRegion(
      name: 'Osaka Central Region',
      size: '180 MB',
      isDownloaded: false,
      downloadProgress: 0.0,
      isDownloading: false,
    ),
    MapRegion(
      name: 'Tokyo Metro Area',
      size: '450 MB',
      isDownloaded: false,
      downloadProgress: 0.0,
    ),
    MapRegion(
      name: 'Nara Historical Sites',
      size: '95 MB',
      isDownloaded: false,
      downloadProgress: 0.0,
    ),
  ];

  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _loadDownloadedMaps();
  }

  @override
  void dispose() {
    _downloadTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDownloadedMaps() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var i = 0; i < _regions.length; i++) {
        final isDownloaded = prefs.getBool('map_${_regions[i].name}') ?? (i == 0); // First one downloaded by default
        _regions[i].isDownloaded = isDownloaded;
        if (isDownloaded) {
          _regions[i].downloadProgress = 1.0;
        }
      }
    });
  }

  Future<void> _saveMapStatus(String mapName, bool isDownloaded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('map_$mapName', isDownloaded);
  }

  void _startDownload(MapRegion region) {
    setState(() {
      region.isDownloading = true;
      region.downloadProgress = 0.0;
    });

    _downloadTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        region.downloadProgress += 0.01;
        if (region.downloadProgress >= 1.0) {
          region.downloadProgress = 1.0;
          region.isDownloading = false;
          region.isDownloaded = true;
          timer.cancel();
          _saveMapStatus(region.name, true);
        }
      });
    });
  }

  void _pauseDownload(MapRegion region) {
    _downloadTimer?.cancel();
    setState(() {
      region.isDownloading = false;
    });
  }

  void _deleteMap(MapRegion region) {
    setState(() {
      region.isDownloaded = false;
      region.isDownloading = false;
      region.downloadProgress = 0.0;
    });
    _saveMapStatus(region.name, false);
  }

  double get _totalStorageUsed {
    return _regions
        .where((r) => r.isDownloaded || r.isDownloading)
        .map((r) => _parseSizeMB(r.size) * (r.isDownloaded ? 1.0 : r.downloadProgress))
        .fold(0.0, (sum, size) => sum + size);
  }

  double _parseSizeMB(String sizeStr) {
    final match = RegExp(r'(\d+)\s*MB').firstMatch(sizeStr);
    return match != null ? double.parse(match.group(1)!) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        title: Text(
          'OFFLINE MAPS',
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
            // Storage Usage Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _deepGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Storage Usage',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalStorageUsed / (45.2 * 1024),
                      minHeight: 20,
                      backgroundColor: const Color(0xFF5A7A5C),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        SolitudeExplorerTheme.compassGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: SolitudeExplorerTheme.compassGold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Maps (${_totalStorageUsed.toStringAsFixed(0)} MB)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5A7A5C),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Free (45.2 GB)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Available Regions
            Text(
              'Available Regions',
              style: GoogleFonts.crimsonText(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SolitudeExplorerTheme.inkBlack,
              ),
            ),
            const SizedBox(height: 12),

            // Region List
            ..._regions.map((region) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SolitudeExplorerTheme.stainedPaper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: region.isDownloaded
                                  ? _deepGreen.withValues(alpha: 0.1)
                                  : SolitudeExplorerTheme.compassGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.map_outlined,
                              color: region.isDownloaded
                                  ? _deepGreen
                                  : SolitudeExplorerTheme.compassGold,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  region.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: SolitudeExplorerTheme.inkBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  region.size,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: SolitudeExplorerTheme.fadedInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildActionButton(region),
                        ],
                      ),
                      if (region.isDownloading) ...[
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: region.downloadProgress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _deepGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${(region.downloadProgress * 100).toInt()}% Downloaded',
                              style: TextStyle(
                                fontSize: 12,
                                color: SolitudeExplorerTheme.fadedInk,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(MapRegion region) {
    if (region.isDownloaded) {
      return GestureDetector(
        onTap: () => _showDeleteDialog(region),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _deepGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        ),
      );
    } else if (region.isDownloading) {
      return GestureDetector(
        onTap: () => _pauseDownload(region),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SolitudeExplorerTheme.compassGold,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pause, color: Colors.white, size: 20),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _startDownload(region),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SolitudeExplorerTheme.inkBlack,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.download, color: Colors.white, size: 20),
        ),
      );
    }
  }

  void _showDeleteDialog(MapRegion region) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Map'),
        content: Text('Are you sure you want to delete ${region.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMap(region);
            },
            style: TextButton.styleFrom(
              foregroundColor: SolitudeExplorerTheme.burgundyRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class MapRegion {
  final String name;
  final String size;
  bool isDownloaded;
  double downloadProgress;
  bool isDownloading;

  MapRegion({
    required this.name,
    required this.size,
    this.isDownloaded = false,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
  });
}
