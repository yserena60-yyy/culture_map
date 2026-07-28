import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'solitude_explorer_theme.dart';
import 'supabase_service.dart';

/// Bottom sheet for checking in to a stamp (or one waypoint of a route).
/// Within 500m of [targetLocation], the user can check in directly with an
/// optional photo/note. Outside that range, a photo is required as proof
/// for a retroactive ("补打卡") check-in.
class CheckInSheet extends StatefulWidget {
  final String stampId;
  final String placeName;
  final LatLng targetLocation;
  final LatLng? currentLocation;
  final int waypointIndex;
  final VoidCallback? onCheckedIn;

  const CheckInSheet({
    super.key,
    required this.stampId,
    required this.placeName,
    required this.targetLocation,
    this.currentLocation,
    this.waypointIndex = 0,
    this.onCheckedIn,
  });

  static const double checkInRangeMeters = 500;

  @override
  State<CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<CheckInSheet> {
  final SupabaseService _supabaseService = SupabaseService();
  final TextEditingController _noteController = TextEditingController();
  XFile? _selectedImage;
  bool _isSubmitting = false;
  String? _error;

  double? get _distanceMeters {
    if (widget.currentLocation == null) return null;
    const distance = Distance();
    return distance.as(
        LengthUnit.Meter, widget.currentLocation!, widget.targetLocation);
  }

  bool get _isWithinRange {
    final d = _distanceMeters;
    return d != null && d <= CheckInSheet.checkInRangeMeters;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _selectedImage = pickedFile);
      }
    } catch (e) {
      debugPrint('Error picking check-in image: $e');
    }
  }

  Future<String?> _uploadImage(XFile imageFile, String userId) async {
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = 'checkins/$fileName';
    final bytes = await imageFile.readAsBytes();
    await Supabase.instance.client.storage
        .from('user-content')
        .uploadBinary(filePath, bytes);
    return Supabase.instance.client.storage
        .from('user-content')
        .getPublicUrl(filePath);
  }

  Future<void> _submit({required bool isBackfill}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _error = 'Please sign in to check in.');
      return;
    }
    if (isBackfill && _selectedImage == null) {
      setState(() => _error = 'A photo is required to back-fill a check-in.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      String? photoUrl;
      if (_selectedImage != null) {
        photoUrl = await _uploadImage(_selectedImage!, user.id);
      }

      await _supabaseService.checkInToStamp(
        stampId: widget.stampId,
        waypointIndex: widget.waypointIndex,
        photoUrl: photoUrl,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        isBackfill: isBackfill,
      );

      if (mounted) {
        widget.onCheckedIn?.call();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Check-in failed: $e';
          _isSubmitting = false;
        });
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final withinRange = _isWithinRange;
    final distance = _distanceMeters;

    return Container(
      decoration: const BoxDecoration(
        color: SolitudeExplorerTheme.stainedPaper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.location_on,
                    color: SolitudeExplorerTheme.compassGold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.placeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: withinRange
                    ? SolitudeExplorerTheme.compassGoldSurface
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    withinRange ? Icons.check_circle : Icons.info_outline,
                    size: 18,
                    color: withinRange
                        ? SolitudeExplorerTheme.compassGold
                        : SolitudeExplorerTheme.fadedInk,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      distance == null
                          ? 'Location unknown — enable location to check in directly, or upload a photo to back-fill this check-in.'
                          : withinRange
                              ? "You're within ${distance.round()}m — you can check in now."
                              : "You're ${(distance / 1000).toStringAsFixed(1)}km away. Upload a photo as proof to back-fill this check-in.",
                      style: TextStyle(
                        fontSize: 13,
                        color: SolitudeExplorerTheme.fadedInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(
                            _selectedImage!.path,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_selectedImage!.path),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _selectedImage = null),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(_selectedImage == null
                  ? (withinRange ? 'Add Photo (optional)' : 'Add Photo (required)')
                  : 'Change Photo'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SolitudeExplorerTheme.compassGold,
                side: BorderSide(color: SolitudeExplorerTheme.compassGold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write a comment or story (optional)',
                hintStyle: TextStyle(
                  color: SolitudeExplorerTheme.fadedInk,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: SolitudeExplorerTheme.stainedPaperEdge),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: SolitudeExplorerTheme.stainedPaperEdge),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: SolitudeExplorerTheme.burgundyRed),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(color: SolitudeExplorerTheme.burgundyRed, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _submit(isBackfill: !withinRange),
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
                    : Text(withinRange ? 'Check In' : 'Back-fill Check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
