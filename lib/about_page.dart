import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'solitude_explorer_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolitudeExplorerTheme.agedYellow,
      appBar: AppBar(
        backgroundColor: SolitudeExplorerTheme.agedYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: SolitudeExplorerTheme.inkBlack, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'About Culture Map',
          style: GoogleFonts.crimsonText(
            color: SolitudeExplorerTheme.inkBlack,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Icon and Version
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5A3F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Culture Map',
                    style: GoogleFonts.cinzel(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: SolitudeExplorerTheme.fadedInk,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About the App',
                    style: GoogleFonts.crimsonText(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Culture Map is your companion for exploring historical landmarks and cultural sites around the world. Discover stories from the past, navigate to ancient locations, and collect stamps as you journey through time.',
                    style: GoogleFonts.crimsonText(
                      fontSize: 15,
                      color: SolitudeExplorerTheme.inkBlack,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Features
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: GoogleFonts.crimsonText(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SolitudeExplorerTheme.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('🗺️', 'Interactive historical maps'),
                  _buildFeatureItem('🧭', 'GPS navigation to landmarks'),
                  _buildFeatureItem('🎫', 'Collect cultural stamps'),
                  _buildFeatureItem('📖', 'Rich Wikipedia integration'),
                  _buildFeatureItem('🌍', 'Offline maps support'),
                  _buildFeatureItem('✍️', 'Community contributions'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Links
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SolitudeExplorerTheme.stainedPaperEdge),
              ),
              child: Column(
                children: [
                  _buildLinkTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _launchURL('https://culturemap.example.com/privacy'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLinkTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    onTap: () => _launchURL('https://culturemap.example.com/terms'),
                  ),
                  const Divider(height: 1, indent: 54),
                  _buildLinkTile(
                    icon: Icons.code_outlined,
                    title: 'Open Source Licenses',
                    onTap: () => _showLicenses(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Copyright
            Text(
              '© 2026 Culture Map\nMade with ❤️ for history explorers',
              textAlign: TextAlign.center,
              style: GoogleFonts.crimsonText(
                fontSize: 13,
                color: SolitudeExplorerTheme.fadedInk,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.crimsonText(
                fontSize: 15,
                color: SolitudeExplorerTheme.inkBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF3D5A3F)),
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Culture Map',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF3D5A3F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.map_outlined, color: Colors.white, size: 30),
      ),
    );
  }
}
