import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  bool _hasMinLength() => password.length >= 8;
  bool _hasUpperAndLower() =>
      password.contains(RegExp(r'[A-Z]')) &&
      password.contains(RegExp(r'[a-z]'));
  bool _hasDigit() => password.contains(RegExp(r'\d'));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirement('Tối thiểu 8 ký tự', _hasMinLength(), isDark),
        const SizedBox(height: 8),
        _buildRequirement(
          'Bao gồm chữ hoa và chữ thường',
          _hasUpperAndLower(),
          isDark,
        ),
        const SizedBox(height: 8),
        _buildRequirement('Bao gồm ít nhất một chữ số', _hasDigit(), isDark),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet, bool isDark) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: isMet
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }
}
