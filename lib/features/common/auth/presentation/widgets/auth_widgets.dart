// ============================================================================
// AUTH REUSABLE WIDGETS
// ============================================================================
// Widget reusable untuk fitur authentication
//
// Clean Code Principles:
// ✅ Reusable - bisa dipakai di login & register
// ✅ Single Responsibility - setiap widget punya 1 tugas
// ✅ Clean naming - nama deskriptif
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_constants.dart';

/// Text field custom untuk auth (email, password, dll)
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    // Untuk register (dengan border outline)
    if (labelText != null) {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        maxLines: maxLines,
        maxLength: maxLength,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRadius.md),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRadius.md),
            borderSide: const BorderSide(color: AuthColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRadius.md),
            borderSide: const BorderSide(
              color: AuthColors.borderFocused,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRadius.md),
            borderSide: const BorderSide(color: AuthColors.borderError),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AuthRadius.md),
            borderSide: const BorderSide(
              color: AuthColors.borderError,
              width: 2,
            ),
          ),
        ),
        validator: validator,
        onChanged: onChanged,
      );
    }

    // Untuk login (dengan underline)
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AuthColors.textHint,
        ),
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AuthColors.border, width: 1.4),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AuthColors.borderFocused, width: 1.6),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AuthColors.borderError, width: 1.4),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AuthColors.borderError, width: 1.6),
        ),
        isDense: true,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}

/// Primary button untuk auth (Login/Register)
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52.0,
    this.borderRadius,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuthColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AuthRadius.xxl,
            ),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text),
      ),
    );
  }
}

/// Password visibility toggle button
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.isObscure,
    required this.onToggle,
  });

  final bool isObscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isObscure ? Icons.visibility_off : Icons.visibility,
        color: AuthColors.textHint,
        size: AuthIconSize.md,
      ),
      onPressed: onToggle,
    );
  }
}

/// Logo widget untuk auth pages
class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    this.size = AuthIconSize.xxl,
    this.showText = true,
  });

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    if (!showText) {
      return Center(
        child: Image.asset(
          'assets/icons/icon.png',
          height: size,
          width: size,
          errorBuilder: (_, __, ___) => Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: AuthColors.primary,
              borderRadius: BorderRadius.circular(AuthRadius.md),
            ),
            child: const Icon(
              Icons.fingerprint,
              color: Colors.white,
              size: AuthIconSize.xl,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/icon.png',
          height: size,
          width: size,
          errorBuilder: (_, __, ___) => Icon(
            Icons.fingerprint,
            size: size,
            color: AuthColors.primary,
          ),
        ),
        const SizedBox(width: AuthSpacing.md),
        Text(
          'Jawara',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AuthColors.primary,
          ),
        ),
      ],
    );
  }
}

/// Info box untuk kredensial default
class DefaultCredentialsInfo extends StatelessWidget {
  const DefaultCredentialsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AuthSpacing.md),
      decoration: BoxDecoration(
        color: AuthColors.primaryLight,
        borderRadius: BorderRadius.circular(AuthRadius.sm),
        border: Border.all(
          color: AuthColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: AuthIconSize.sm,
                color: AuthColors.primary,
              ),
              const SizedBox(width: AuthSpacing.sm),
              Text(
                'Kredensial Default:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AuthColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AuthSpacing.sm),
          Text(
            'Email: ${AuthDefaults.defaultEmail}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AuthColors.textSecondary,
            ),
          ),
          const SizedBox(height: AuthSpacing.xs),
          Text(
            'Password: ${AuthDefaults.defaultPassword}',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AuthColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error dialog helper
class AuthDialogs {
  AuthDialogs._();

  /// Show error dialog
  static void showError(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: AuthColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog dengan callback
  static void showSuccess(
    BuildContext context,
    String title,
    String message, {
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: onPressed ??
                () {
                  Navigator.pop(context);
                },
            child: Text(
              buttonText,
              style: GoogleFonts.poppins(color: AuthColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

