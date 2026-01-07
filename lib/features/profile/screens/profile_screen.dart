import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrd_app/core/utils/string_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:hrd_app/core/providers/theme_provider.dart';
import 'package:hrd_app/core/theme/app_colors.dart';
import 'package:hrd_app/routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';

  // Dummy user data
  final Map<String, String> _user = {
    'name': 'Sarul Padillah',
    'role': 'CASHIER',
  };

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v ${packageInfo.version} - ${packageInfo.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colors.textPrimary),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header
            _buildUserHeader(colors),
            const SizedBox(height: 16),

            // Menu Items
            _buildMenuSection(colors, [
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Profil Saya',
                onTap: () {
                  // TODO: Navigate to profile detail
                },
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan Personal',
                onTap: () {
                  // TODO: Navigate to settings
                },
                showBackground: true,
              ),
              _MenuItem(
                icon: Icons.local_parking_outlined,
                title: 'EZ Parking',
                onTap: () {
                  // TODO: Navigate to parking
                },
              ),
            ]),
            const SizedBox(height: 16),
            Divider(height: 1, thickness: 5, color: colors.divider),
            // Settings Section
            _buildSettingsSection(colors, themeProvider),
            const SizedBox(height: 16),

            // Logout
            _buildLogoutSection(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(dynamic colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.divider, width: 2),
            ),
            child: Center(
              child: Text(
                StringUtils.getInitials(_user['name'] ?? ""),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name & Role
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hai, ${_user['name']}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _user['role']!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(dynamic colors, List<_MenuItem> items) {
    return Container(
      color: colors.background,
      child: Column(
        children: items.map((item) {
          return _buildMenuItem(colors, item);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(dynamic colors, _MenuItem item) {
    return Container(
      color: item.showBackground ? colors.surface : colors.background,
      child: ListTile(
        leading: Icon(item.icon, color: colors.textSecondary),
        title: Text(
          item.title,
          style: GoogleFonts.inter(fontSize: 16, color: colors.textPrimary),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.inactiveGray),
        onTap: item.onTap,
      ),
    );
  }

  Widget _buildSettingsSection(dynamic colors, ThemeProvider themeProvider) {
    return Container(
      color: colors.background,
      child: Column(
        children: [
          // Theme Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    themeProvider.modeLabel,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeThumbColor: colors.primaryBlue,
                ),
              ],
            ),
          ),

          // Kebijakan Privasi
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: colors.textSecondary,
            ),
            title: Text(
              'Kebijakan Privasi',
              style: GoogleFonts.inter(fontSize: 16, color: colors.textPrimary),
            ),
            trailing: Icon(Icons.chevron_right, color: colors.inactiveGray),
            onTap: () {
              // TODO: Navigate to privacy policy
            },
          ),

          // Bantuan & Dukungan
          ListTile(
            leading: Icon(Icons.help_outline, color: colors.textSecondary),
            title: Text(
              'Bantuan & Dukungan',
              style: GoogleFonts.inter(fontSize: 16, color: colors.textPrimary),
            ),
            trailing: Icon(Icons.chevron_right, color: colors.inactiveGray),
            onTap: () {
              // TODO: Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Keluar',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.logout, color: colors.error),
            label: Text(
              'Keluar',
              style: GoogleFonts.inter(fontSize: 16, color: colors.error),
            ),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
          ),
          Text(
            _appVersion,
            style: GoogleFonts.inter(fontSize: 14, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showBackground;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showBackground = false,
  });
}
