import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/utils/shared_pref.dart';

/// Preset background options using bundled asset images.
enum PresetBackground {
  none,
  nature,
  ocean,
  mountain,
  city,
  abstract_,
}

extension PresetBackgroundExt on PresetBackground {
  String get assetPath {
    switch (this) {
      case PresetBackground.nature:
        return 'assets/images/land.png';
      case PresetBackground.ocean:
        return 'assets/images/ocean.jpeg';
      case PresetBackground.mountain:
        return 'assets/images/mountain.jpeg';
      case PresetBackground.city:
        return 'assets/images/city.jpeg';
      case PresetBackground.abstract_:
        return 'assets/images/image.png';
      default:
        return '';
    }
  }

  String get label {
    switch (this) {
      case PresetBackground.nature:   return 'Nature';
      case PresetBackground.ocean:    return 'Ocean';
      case PresetBackground.mountain: return 'Mountain';
      case PresetBackground.city:     return 'City';
      case PresetBackground.abstract_: return 'Abstract';
      default: return 'None';
    }
  }

  Color get previewColor {
    switch (this) {
      case PresetBackground.nature:   return const Color(0xFF4CAF50);
      case PresetBackground.ocean:    return const Color(0xFF1E88E5);
      case PresetBackground.mountain: return const Color(0xFF7E57C2);
      case PresetBackground.city:     return const Color(0xFFE91E63);
      case PresetBackground.abstract_: return const Color(0xFF3F51B5);
      default: return Colors.grey;
    }
  }
}

class ThemeState {
  final ThemeMode themeMode;

  /// Preset background (if any).
  final PresetBackground preset;

  /// Absolute file path to a user-picked background image.
  /// Empty string = no custom image.
  final String customImagePath;

  const ThemeState({
    required this.themeMode,
    this.preset = PresetBackground.none,
    this.customImagePath = '',
  });

  /// True when any background (preset or custom) is active.
  bool get hasBackground =>
      preset != PresetBackground.none || customImagePath.isNotEmpty;

  /// True when the active background is an asset (preset).
  bool get isAssetBackground =>
      preset != PresetBackground.none && customImagePath.isEmpty;

  /// The effective image path: custom file path OR asset path from preset.
  String get backgroundImagePath =>
      customImagePath.isNotEmpty ? customImagePath : preset.assetPath;

  ThemeState copyWith({
    ThemeMode? themeMode,
    PresetBackground? preset,
    String? customImagePath,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      preset: preset ?? this.preset,
      customImagePath: customImagePath ?? this.customImagePath,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.light)) {
    _loadPrefs();
  }

  static const _themeKey     = 'theme_mode';
  static const _presetKey    = 'preset_background';
  static const _bgImageKey   = 'background_image_path';

  void toggleTheme(bool isDark) {
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
    SharedPref().saveBool(_themeKey, isDark);
  }

  /// Activate a preset background (clears any custom image).
  void setPreset(PresetBackground preset) {
    emit(state.copyWith(preset: preset, customImagePath: ''));
    SharedPref().saveString(_presetKey, preset.name);
    SharedPref().saveString(_bgImageKey, '');
  }

  /// Set a custom background image by absolute file path (clears preset).
  void setBackgroundImage(String path) {
    emit(state.copyWith(preset: PresetBackground.none, customImagePath: path));
    SharedPref().saveString(_presetKey, PresetBackground.none.name);
    SharedPref().saveString(_bgImageKey, path);
  }

  /// Remove all backgrounds.
  void clearBackgroundImage() {
    emit(state.copyWith(preset: PresetBackground.none, customImagePath: ''));
    SharedPref().saveString(_presetKey, PresetBackground.none.name);
    SharedPref().saveString(_bgImageKey, '');
  }

  Future<void> _loadPrefs() async {
    final isDark   = await SharedPref().getBool(_themeKey) ?? false;
    final imgPath  = await SharedPref().getString(_bgImageKey) ?? '';
    final presetName = await SharedPref().getString(_presetKey) ?? 'none';

    final preset = PresetBackground.values.firstWhere(
      (e) => e.name == presetName,
      orElse: () => PresetBackground.none,
    );

    emit(ThemeState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      preset: imgPath.isNotEmpty ? PresetBackground.none : preset,
      customImagePath: imgPath,
    ));
  }
}
