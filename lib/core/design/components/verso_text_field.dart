import 'package:flutter/material.dart';
import 'package:verso_admin/core/design/tokens/radii.dart';
import 'package:verso_admin/core/design/tokens/spacing.dart';
import 'package:verso_admin/core/design/tokens/typography.dart';

/// Styled text field used across auth and form screens.
///
/// Supports both [TextFormField] (with [validator]) and plain [TextField] usage.
///
/// ```dart
/// VersoTextField(
///   controller: _emailController,
///   label: 'Email',
///   icon: Icons.mail_outline_rounded,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class VersoTextField extends StatelessWidget {
  const VersoTextField({
    required this.controller,
    required this.label,
    super.key,
    this.icon = Icons.edit_note_rounded,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.autocorrect = true,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool autocorrect;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration = InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ).copyWith(color: colorScheme.onSurfaceVariant),
      floatingLabelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ).copyWith(color: colorScheme.primary),
      prefixIcon: icon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme.primary.withValues(alpha: 0.75),
              ),
            )
          : null,
      prefixIconConstraints:
          icon != null ? const BoxConstraints(minWidth: 44) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadii.borderRadiusMD,
        borderSide: BorderSide(color: colorScheme.error, width: 1.8),
      ),
    );

    final style = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurface,
    );

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: style,
      decoration: decoration,
      validator: validator,
    );
  }
}
