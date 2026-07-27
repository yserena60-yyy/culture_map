import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'solitude_explorer_theme.dart';
import 'personal_info_page.dart';
import 'privacy_security_page.dart';
import 'language_settings_page.dart';
import 'about_page.dart';
import 'help_feedback_page.dart';
import 'help_feedback_page_new.dart';
import 'offline_maps_page_new.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _offlineMode = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? false;
      _offlineMode = prefs.getBool('offlineMode') ?? false;
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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
        title: Text(
          'Settings',
          style: GoogleFonts.crimsonText(
            color: SolitudeExplorerTheme.inkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSectionHeader('ACCOUNT'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Personal Info',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalInfoPage()),
              ),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacySecurityPage()),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('PREFERENCES'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              value: _pushNotifications,
              onChanged: (v) {
                setState(() => _pushNotifications = v);
                _saveSetting('pushNotifications', v);
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              value: _emailNotifications,
              onChanged: (v) {
                setState(() => _emailNotifications = v);
                _saveSetting('emailNotifications', v);
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.cloud_off_outlined,
              title: 'Offline Mode (Wi-Fi Only)',
              value: _offlineMode,
              onChanged: (v) {
                setState(() => _offlineMode = v);
                _saveSetting('offlineMode', v);
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _darkMode,
              onChanged: (v) {
                setState(() => _darkMode = v);
                _saveSetting('darkMode', v);
                // TODO: Implement theme change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dark mode coming soon!')),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              trailing: 'English',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageSettingsPage()),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('MAPS & STORAGE'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.map_outlined,
              title: 'Offline Maps',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OfflineMapsPageNew()),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('SUPPORT & ABOUT'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpFeedbackPageNew()),
              ),
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About Culture Map',
              trailing: 'v1.0.0',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSignOutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SolitudeExplorerTheme.fadedInk,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: SolitudeExplorerTheme.burgundyRed),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: SolitudeExplorerTheme.inkBlack,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 14,
                  color: SolitudeExplorerTheme.fadedInk,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: SolitudeExplorerTheme.fadedInk,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: SolitudeExplorerTheme.burgundyRed),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: SolitudeExplorerTheme.inkBlack,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3D5A3F), // Deep green to match offline maps
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 54,
      endIndent: 16,
      color: SolitudeExplorerTheme.stainedPaperEdge,
    );
  }

  Widget _buildSignOutButton() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton(
        onPressed: () async {
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/',
              (route) => false,
            );
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: SolitudeExplorerTheme.burgundyRed,
          side: const BorderSide(color: SolitudeExplorerTheme.burgundyRed),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Sign Out',
        ),
      ),
    );
  }
}
