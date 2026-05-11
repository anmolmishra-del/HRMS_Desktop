import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _autoCheckInEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Default';

  // Available theme backgrounds
  final List<Map<String, dynamic>> _themeOptions = [
    {
      'name': 'Default',
      'description': 'Clean white background',
      'preview': Colors.white,
    },
    {
      'name': 'Nature',
      'description': 'Peaceful nature landscape',
      'preview': const Color(0xFFE8F5E8),
    },
    {
      'name': 'Ocean',
      'description': 'Calm ocean waves',
      'preview': const Color(0xFFE3F2FD),
    },
    {
      'name': 'Mountain',
      'description': 'Majestic mountain peaks',
      'preview': const Color(0xFFF3E5F5),
    },
    {
      'name': 'City',
      'description': 'Urban city skyline',
      'preview': const Color(0xFFFCE4EC),
    },
    {
      'name': 'Abstract',
      'description': 'Modern abstract patterns',
      'preview': const Color(0xFFE8EAF6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Settings ⚙️",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Customize your experience",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest_rounded),
                    const SizedBox(width: 10),
                    Text(
                      "v1.0.0",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// PROFILE SECTION
          _buildSectionCard(
            title: "Profile Settings",
            icon: Icons.person_rounded,
            children: [
              _buildProfileTile(),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: "Edit Profile",
                subtitle: "Update your personal information",
                icon: Icons.edit_rounded,
                onTap: () {},
              ),
              _buildSettingTile(
                title: "Change Password",
                subtitle: "Update your account password",
                icon: Icons.lock_rounded,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// APP PREFERENCES
          _buildSectionCard(
            title: "App Preferences",
            icon: Icons.app_settings_alt_rounded,
            children: [
              _buildSwitchTile(
                title: "Push Notifications",
                subtitle: "Receive notifications for check-in/out reminders",
                icon: Icons.notifications_rounded,
                value: _notificationsEnabled,
                onChanged: (value) => setState(() => _notificationsEnabled = value),
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: "Dark Mode",
                subtitle: "Switch to dark theme",
                icon: Icons.dark_mode_rounded,
                value: _darkModeEnabled,
                onChanged: (value) => setState(() => _darkModeEnabled = value),
              ),
              const SizedBox(height: 16),
              _buildDropdownTile(
                title: "Language",
                subtitle: "Choose your preferred language",
                icon: Icons.language_rounded,
                value: _selectedLanguage,
                items: ['English', 'Spanish', 'French', 'German'],
                onChanged: (value) => setState(() => _selectedLanguage = value!),
              ),
              const SizedBox(height: 16),
              _buildThemeSelector(),
            ],
          ),

          const SizedBox(height: 24),

          /// WORK SETTINGS
          _buildSectionCard(
            title: "Work Settings",
            icon: Icons.work_rounded,
            children: [
              _buildSwitchTile(
                title: "Biometric Authentication",
                subtitle: "Use fingerprint/face ID for check-in/out",
                icon: Icons.fingerprint_rounded,
                value: _biometricEnabled,
                onChanged: (value) => setState(() => _biometricEnabled = value),
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: "Auto Check-in",
                subtitle: "Automatically check-in when opening the app",
                icon: Icons.auto_mode_rounded,
                value: _autoCheckInEnabled,
                onChanged: (value) => setState(() => _autoCheckInEnabled = value),
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: "Working Hours",
                subtitle: "Set your default working hours",
                icon: Icons.schedule_rounded,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// DATA & PRIVACY
          _buildSectionCard(
            title: "Data & Privacy",
            icon: Icons.security_rounded,
            children: [
              _buildSettingTile(
                title: "Export Data",
                subtitle: "Download your attendance and productivity data",
                icon: Icons.download_rounded,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: "Privacy Policy",
                subtitle: "Read our privacy policy",
                icon: Icons.privacy_tip_rounded,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: "Terms of Service",
                subtitle: "Read our terms and conditions",
                icon: Icons.description_rounded,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// SUPPORT
          _buildSectionCard(
            title: "Support & Help",
            icon: Icons.help_rounded,
            children: [
              _buildSettingTile(
                title: "Help Center",
                subtitle: "Find answers to common questions",
                icon: Icons.help_center_rounded,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: "Contact Support",
                subtitle: "Get in touch with our support team",
                icon: Icons.support_agent_rounded,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildSettingTile(
                title: "Report a Bug",
                subtitle: "Help us improve by reporting issues",
                icon: Icons.bug_report_rounded,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// LOGOUT SECTION
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingTile(
                  title: "Logout",
                  subtitle: "Sign out from your account",
                  icon: Icons.logout_rounded,
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () async {
                    await context.read<LoginCubit>().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.deepPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileTile() {
    return FutureBuilder(
      future: SharedPref().getObject('employee_data'),
      builder: (context, snapshot) {
        String employeeName = "Employee";
        String employeePost = "Staff";
        String employeeEmail = "employee@company.com";

        if (snapshot.hasData && snapshot.data != null) {
          final employee = snapshot.data as Map<String, dynamic>;
          employeeName = employee['name']?.toString() ?? "Employee";
          employeePost = employee['job_title']?.toString() ?? "Staff";
          employeeEmail = employee['email']?.toString() ?? "employee@company.com";
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepPurple.shade200,
                child: Text(
                  employeeName.isNotEmpty ? employeeName[0].toUpperCase() : "E",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employeeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employeePost,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employeeEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.deepPurple).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.deepPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: Icon(
              Icons.arrow_drop_down_rounded,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette_rounded,
                color: Colors.deepPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Background Theme",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Choose your preferred background",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _themeOptions.length,
            itemBuilder: (context, index) {
              final theme = _themeOptions[index];
              final isSelected = theme['name'] == _selectedTheme;

              return GestureDetector(
                onTap: () => setState(() => _selectedTheme = theme['name']),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: theme['preview'],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Background pattern simulation
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            gradient: LinearGradient(
                              colors: [
                                theme['preview'].withOpacity(0.3),
                                theme['preview'].withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                      // Theme name and checkmark
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme['name'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.deepPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}