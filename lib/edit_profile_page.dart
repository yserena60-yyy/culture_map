import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'solitude_explorer_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _avatarUrl;
  XFile? _selectedImageFile; // Store XFile from picker
  int _userLevel = 1;
  int _totalComments = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Load user metadata
      final metadata = user.userMetadata;
      _nameController.text = metadata?['display_name'] ?? user.email?.split('@').first ?? 'Traveler';
      _bioController.text = metadata?['bio'] ?? '';
      _avatarUrl = metadata?['avatar_url'];

      // Load user stats for level calculation
      final commentsResponse = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('user_id', user.id);

      _totalComments = commentsResponse.length;
      _userLevel = _calculateLevel(_totalComments);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _calculateLevel(int comments) {
    if (comments >= 50) return 5;
    if (comments >= 20) return 4;
    if (comments >= 10) return 3;
    if (comments >= 5) return 2;
    return 1;
  }

  String _getLevelTitle(int level) {
    switch (level) {
      case 5: return 'Master Explorer';
      case 4: return 'Expert Traveler';
      case 3: return 'Seasoned Wanderer';
      case 2: return 'Curious Explorer';
      default: return 'Novice Traveler';
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = pickedFile;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error selecting image',
              style: GoogleFonts.crimsonText(fontSize: 15),
            ),
          ),
        );
      }
    }
  }

  Future<String?> _uploadAvatar(XFile imageFile) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;

      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'avatars/$fileName';

      final bytes = await imageFile.readAsBytes();
      await Supabase.instance.client.storage
          .from('user-content')
          .uploadBinary(filePath, bytes);

      final publicUrl = Supabase.instance.client.storage
          .from('user-content')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      String? newAvatarUrl = _avatarUrl;

      // Upload new avatar if selected
      if (_selectedImageFile != null) {
        newAvatarUrl = await _uploadAvatar(_selectedImageFile!);
        if (newAvatarUrl == null) {
          throw Exception('Failed to upload avatar');
        }
      }

      // Update user metadata
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'display_name': _nameController.text.trim(),
            'bio': _bioController.text.trim(),
            if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully',
              style: GoogleFonts.crimsonText(fontSize: 15),
            ),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate profile was updated
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating profile: $e',
              style: GoogleFonts.crimsonText(fontSize: 15),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
          'Edit Profile',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: SolitudeExplorerTheme.inkBlack,
          ),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SolitudeExplorerTheme.compassGold,
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.crimsonText(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SolitudeExplorerTheme.compassGold,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SolitudeExplorerTheme.compassGold,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SolitudeExplorerTheme.compassGold,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedImageFile != null
                                ? (kIsWeb
                                    ? Image.network(_selectedImageFile!.path, fit: BoxFit.cover)
                                    : Image.file(File(_selectedImageFile!.path), fit: BoxFit.cover))
                                : _avatarUrl != null
                                    ? Image.network(_avatarUrl!, fit: BoxFit.cover)
                                    : Container(
                                        color: SolitudeExplorerTheme.compassGold.withValues(alpha: 0.2),
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: SolitudeExplorerTheme.compassGold,
                                        ),
                                      ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: SolitudeExplorerTheme.compassGold,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to change photo',
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: SolitudeExplorerTheme.fadedInk,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Level display (read-only)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SolitudeExplorerTheme.stainedPaper,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: SolitudeExplorerTheme.stainedPaperEdge,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: SolitudeExplorerTheme.compassGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv.$_userLevel',
                            style: GoogleFonts.crimsonText(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLevelTitle(_userLevel),
                                style: GoogleFonts.crimsonText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: SolitudeExplorerTheme.inkBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_totalComments ${_totalComments == 1 ? 'comment' : 'comments'}',
                                style: GoogleFonts.crimsonText(
                                  fontSize: 13,
                                  color: SolitudeExplorerTheme.fadedInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.crimsonText(
                      fontSize: 16,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: GoogleFonts.crimsonText(
                        color: SolitudeExplorerTheme.fadedInk,
                      ),
                      filled: true,
                      fillColor: SolitudeExplorerTheme.stainedPaper,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SolitudeExplorerTheme.stainedPaperEdge,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SolitudeExplorerTheme.stainedPaperEdge,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SolitudeExplorerTheme.compassGold,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLength: 30,
                  ),
                  const SizedBox(height: 16),

                  // Bio field
                  TextField(
                    controller: _bioController,
                    style: GoogleFonts.crimsonText(
                      fontSize: 16,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Bio',
                      labelStyle: GoogleFonts.crimsonText(
                        color: SolitudeExplorerTheme.fadedInk,
                      ),
                      hintText: 'Tell us about yourself...',
                      hintStyle: GoogleFonts.crimsonText(
                        color: SolitudeExplorerTheme.fadedInk.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: SolitudeExplorerTheme.stainedPaper,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SolitudeExplorerTheme.stainedPaperEdge,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SolitudeExplorerTheme.stainedPaperEdge,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: SolitudeExplorerTheme.compassGold,
                          width: 2,
                        ),
                      ),
                    ),
                    maxLines: 4,
                    maxLength: 150,
                  ),
                ],
              ),
            ),
    );
  }
}
