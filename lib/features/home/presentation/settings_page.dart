import 'dart:io' as dart_io;
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hrms_desktop/core/theme/theme_cubit.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';
import 'package:hrms_desktop/core/localization/app_localization.dart';
import 'package:hrms_desktop/core/services/auto_checkin_service.dart';
import 'package:hrms_desktop/features/attendance/cubit/attendance_cubit.dart';
import 'package:hrms_desktop/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoCheckInEnabled = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
    _loadAutoCheckInSetting();
  }

  void _loadCurrentLanguage() {
    final currentLocale = AppLocalization().currentLocale;
    final languageName = AppLocalization().getLanguageName(currentLocale);
    setState(() {
      _selectedLanguage = languageName;
    });
  }

  Future<void> _loadAutoCheckInSetting() async {
    final isEnabled = await AutoCheckInService.isAutoCheckInEnabled();
    if (mounted) {
      setState(() {
        _autoCheckInEnabled = isEnabled;
      });
    }
  }

  Future<void> _toggleAutoCheckIn(bool value) async {
    setState(() {
      _autoCheckInEnabled = value;
    });
    await SharedPref().saveBool('auto_check_in_enabled', value);
  }

  Future<void> _pickBackgroundImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      context.read<ThemeCubit>().setBackgroundImage(
        result.files.single.path!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isGlass = themeState.hasBackground;
        final isDark = themeState.themeMode == ThemeMode.dark;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppLocalizations.of(context).settings} ⚙️",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).customizeYourExperience,
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isGlass 
                        ? (isDark ? Colors.black.withAlpha(76) : Colors.white.withAlpha(76))
                        : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: isGlass ? Border.all(color: Colors.white.withAlpha(51)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
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
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                title: AppLocalizations.of(context).profileSettings,
                icon: Icons.person_rounded,
                children: [
                  _buildProfileTile(),
                ],
              ),

              const SizedBox(height: 24),

              /// APP PREFERENCES
              _buildSectionCard(
                title: AppLocalizations.of(context).appPreferences,
                icon: Icons.app_settings_alt_rounded,
                children: [
                  _buildSwitchTile(
                    title: AppLocalizations.of(context).darkMode,
                    subtitle: AppLocalizations.of(context).switchToDarkTheme,
                    icon: Icons.dark_mode_rounded,
                    value: themeState.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().toggleTheme(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownTile(
                    title: AppLocalizations.of(context).language,
                    subtitle: AppLocalizations.of(context).chooseYourPreferredLanguage,
                    icon: Icons.language_rounded,
                    value: _selectedLanguage,
                    items: const ['English', 'Hindi', 'Telugu'],
                    onChanged: (value) async {
                      if (value != null) {
                        final localeMap = {
                          'English': const Locale('en'),
                          'Hindi': const Locale('hi'),
                          'Telugu': const Locale('te'),
                        };
                        await AppLocalization().setLocale(localeMap[value]!);
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildThemeSelector(themeState),
                ],
              ),

              const SizedBox(height: 24),

              /// WORK SETTINGS
              _buildSectionCard(
                title: AppLocalizations.of(context).workSettings,
                icon: Icons.work_rounded,
                children: [
                  _buildSwitchTile(
                    title: AppLocalizations.of(context).autoCheckIn,
                    subtitle: AppLocalizations.of(context).automaticallyCheckIn,
                    icon: Icons.auto_mode_rounded,
                    value: _autoCheckInEnabled,
                    onChanged: _toggleAutoCheckIn,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    title: AppLocalizations.of(context).workingHours,
                    subtitle: AppLocalizations.of(context).setDefaultWorkingHours,
                    icon: Icons.schedule_rounded,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// DATA & PRIVACY
              _buildSectionCard(
                title: AppLocalizations.of(context).dataAndPrivacy,
                icon: Icons.security_rounded,
                children: [
                  _buildSettingTile(
                    title: AppLocalizations.of(context).exportData,
                    subtitle: AppLocalizations.of(context).downloadAttendanceData,
                    icon: Icons.download_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    title: AppLocalizations.of(context).privacyPolicy,
                    subtitle: AppLocalizations.of(context).readPrivacyPolicy,
                    icon: Icons.privacy_tip_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    title: AppLocalizations.of(context).termsOfService,
                    subtitle: AppLocalizations.of(context).readTermsConditions,
                    icon: Icons.description_rounded,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// SUPPORT
              _buildSectionCard(
                title: AppLocalizations.of(context).supportAndHelp,
                icon: Icons.help_rounded,
                children: [
                  _buildSettingTile(
                    title: AppLocalizations.of(context).helpCenter,
                    subtitle: AppLocalizations.of(context).findAnswers,
                    icon: Icons.help_center_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    title: AppLocalizations.of(context).contactSupport,
                    subtitle: AppLocalizations.of(context).getInTouch,
                    icon: Icons.support_agent_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    title: AppLocalizations.of(context).reportABug,
                    subtitle: AppLocalizations.of(context).helpUsImprove,
                    icon: Icons.bug_report_rounded,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// LOGOUT SECTION
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: isGlass ? 10 : 0, sigmaY: isGlass ? 10 : 0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isGlass 
                        ? (isDark ? Colors.black.withAlpha(76) : Colors.white.withAlpha(76))
                        : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: isGlass ? Border.all(color: Colors.white.withAlpha(51)) : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          title: AppLocalizations.of(context).logout,
                          subtitle: AppLocalizations.of(context).signOutFromAccount,
                          icon: Icons.logout_rounded,
                          iconColor: Colors.red,
                          textColor: Colors.red,
                          onTap: () async {
                            final attendanceCubit = context.read<AttendanceCubit>();
                            if (attendanceCubit.state.isCheckedIn) {
                              await attendanceCubit.toggleAttendance();
                            }
                            attendanceCubit.reset();
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
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final themeState = context.watch<ThemeCubit>().state;
    final isGlass = themeState.hasBackground;
    final isDark = themeState.themeMode == ThemeMode.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isGlass ? 10 : 0, sigmaY: isGlass ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isGlass 
              ? (isDark ? Colors.black.withAlpha(76) : Colors.white.withAlpha(76))
              : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: isGlass ? Border.all(color: Colors.white.withAlpha(51)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
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
                      color: Colors.deepPurple.withAlpha(26),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
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
            color: Colors.grey.withAlpha(13),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
                color: (iconColor ?? Colors.deepPurple).withAlpha(26),
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
                      color: textColor ?? Theme.of(context).colorScheme.onSurface,
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
            color: Colors.deepPurple.withAlpha(26),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
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
            color: Colors.deepPurple.withAlpha(26),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
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
            color: Colors.grey.withAlpha(26),
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

  Widget _buildThemeSelector(ThemeState themeState) {
    final presets = [
      PresetBackground.none,
      PresetBackground.nature,
      PresetBackground.ocean,
      PresetBackground.mountain,
      PresetBackground.city,
      PresetBackground.abstract_,
    ];

    final presetLabels = {
      PresetBackground.none:      AppLocalizations.of(context).none,
      PresetBackground.nature:    AppLocalizations.of(context).nature,
      PresetBackground.ocean:     AppLocalizations.of(context).ocean,
      PresetBackground.mountain:  AppLocalizations.of(context).mountain,
      PresetBackground.city:      AppLocalizations.of(context).city,
      PresetBackground.abstract_: AppLocalizations.of(context).abstract_,
    };

    final presetColors = {
      PresetBackground.none:      Colors.grey.shade300,
      PresetBackground.nature:    const Color(0xFF4CAF50),
      PresetBackground.ocean:     const Color(0xFF1E88E5),
      PresetBackground.mountain:  const Color(0xFF7E57C2),
      PresetBackground.city:      const Color(0xFFE91E63),
      PresetBackground.abstract_: const Color(0xFF3F51B5),
    };

    final presetGradients = {
      PresetBackground.none:      [Colors.grey.shade200, Colors.grey.shade400],
      PresetBackground.nature:    [const Color(0xFF66BB6A), const Color(0xFF2E7D32)],
      PresetBackground.ocean:     [const Color(0xFF42A5F5), const Color(0xFF0D47A1)],
      PresetBackground.mountain:  [const Color(0xFFAB47BC), const Color(0xFF4A148C)],
      PresetBackground.city:      [const Color(0xFFEC407A), const Color(0xFF880E4F)],
      PresetBackground.abstract_: [const Color(0xFF5C6BC0), const Color(0xFF1A237E)],
    };

    final activePreset = themeState.isAssetBackground
        ? themeState.preset
        : (themeState.hasBackground ? null : PresetBackground.none);

    final hasCustom = themeState.customImagePath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wallpaper_rounded, color: Colors.deepPurple, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).backgroundTheme,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  hasCustom
                      ? AppLocalizations.of(context).customPhotoIsActive
                      : (activePreset == PresetBackground.none || activePreset == null)
                          ? AppLocalizations.of(context).choosePresetOrAddPhoto
                          : "${presetLabels[activePreset]} ${AppLocalizations.of(context).presetActive}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Preset tiles row
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final p = presets[index];
              final isSelected = !hasCustom && activePreset == p;
              final gradient = presetGradients[p]!;

              return GestureDetector(
                onTap: () => context.read<ThemeCubit>().setPreset(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 78,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: p == PresetBackground.none
                        ? null
                        : LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: p == PresetBackground.none
                        ? Theme.of(context).colorScheme.surface
                        : null,
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepPurple
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (presetColors[p] ?? Colors.deepPurple).withAlpha(102),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Label at bottom
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Text(
                          presetLabels[p]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: p == PresetBackground.none
                                ? Theme.of(context).colorScheme.onSurface.withAlpha(178)
                                : Colors.white,
                            shadows: p != PresetBackground.none
                                ? [const Shadow(color: Colors.black38, blurRadius: 4)]
                                : null,
                          ),
                        ),
                      ),
                      // Check icon when selected
                      if (isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 10, color: Colors.deepPurple),
                          ),
                        ),
                      // None icon
                      if (p == PresetBackground.none)
                        const Positioned(
                          top: 12,
                          left: 0,
                          right: 0,
                          child: Icon(Icons.block_rounded, color: Colors.grey, size: 22),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 14),

        // Custom photo row
        Row(
          children: [
            // Preview thumbnail
            if (hasCustom) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  dart_io.File(themeState.customImagePath),
                  width: 72,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 10),
            ],
            // Add / Change Photo button
            Expanded(
              child: GestureDetector(
                onTap: _pickBackgroundImage,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasCustom
                          ? Colors.deepPurple
                          : Colors.deepPurple.withAlpha(89),
                      width: hasCustom ? 2 : 1.5,
                    ),
                    color: hasCustom
                        ? Colors.deepPurple.withAlpha(20)
                        : Colors.deepPurple.withAlpha(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        hasCustom
                            ? Icons.change_circle_outlined
                            : Icons.add_photo_alternate_outlined,
                        color: Colors.deepPurple,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasCustom ? AppLocalizations.of(context).changePhoto : AppLocalizations.of(context).addCustomPhoto,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Remove custom photo button
            if (hasCustom) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.read<ThemeCubit>().clearBackgroundImage(),
                child: Container(
                  width: 52,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withAlpha(102), width: 1.5),
                    color: Colors.red.withAlpha(13),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                      const SizedBox(height: 2),
                      Text(AppLocalizations.of(context).remove, style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}