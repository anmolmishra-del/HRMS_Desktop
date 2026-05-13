import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_desktop/core/theme/theme_cubit.dart';

/// A card widget that shows frosted-glass when a background (preset or custom) is active.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.blur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isGlass = state.hasBackground;
        final isDark  = state.themeMode == ThemeMode.dark;

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isGlass ? blur : 0,
              sigmaY: isGlass ? blur : 0,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: isGlass
                    ? (isDark
                        ? Colors.black.withOpacity(0.35)
                        : Colors.white.withOpacity(0.35))
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(borderRadius),
                border: isGlass
                    ? Border.all(color: Colors.white.withOpacity(0.25), width: 1)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
