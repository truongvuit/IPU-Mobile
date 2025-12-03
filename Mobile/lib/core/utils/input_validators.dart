import 'package:flutter/services.dart';

class InputValidators {
  InputValidators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }

    if (_containsDangerousCharacters(value)) {
      return 'Email chứa ký tự không hợp lệ';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email không đúng định dạng';
    }

    if (value.length > 254) {
      return 'Email quá dài';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');

    final phoneRegex = RegExp(r'^0[0-9]{9,10}$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Số điện thoại không hợp lệ (phải 10-11 số, bắt đầu bằng 0)';
    }

    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên không được để trống';
    }

    if (_containsDangerousCharacters(value)) {
      return 'Tên chứa ký tự không hợp lệ';
    }

    if (value.length < 2) {
      return 'Tên quá ngắn (tối thiểu 2 ký tự)';
    }

    if (value.length > 100) {
      return 'Tên quá dài (tối đa 100 ký tự)';
    }

    final nameRegex = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$', unicode: true);

    if (!nameRegex.hasMatch(value)) {
      return 'Tên chỉ được chứa chữ cái và khoảng trắng';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    if (value.length > 128) {
      return 'Mật khẩu quá dài (tối đa 128 ký tự)';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }

    return null;
  }

  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (_containsDangerousCharacters(value)) {
      return 'Địa chỉ chứa ký tự không hợp lệ';
    }

    if (value.length > 500) {
      return 'Địa chỉ quá dài';
    }

    return null;
  }

  static String? score(String? value, {double max = 10.0}) {
    if (value == null || value.isEmpty) {
      return 'Điểm không được để trống';
    }

    final score = double.tryParse(value);
    if (score == null) {
      return 'Điểm phải là số';
    }

    if (score < 0) {
      return 'Điểm không được âm';
    }

    if (score > max) {
      return 'Điểm không được vượt quá $max';
    }

    return null;
  }

  static String? text(
    String? value, {
    int? minLength,
    int? maxLength,
    bool required = false,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Trường này không được để trống' : null;
    }

    if (_containsDangerousCharacters(value)) {
      return 'Văn bản chứa ký tự không hợp lệ';
    }

    if (minLength != null && value.length < minLength) {
      return 'Văn bản quá ngắn (tối thiểu $minLength ký tự)';
    }

    if (maxLength != null && value.length > maxLength) {
      return 'Văn bản quá dài (tối đa $maxLength ký tự)';
    }

    return null;
  }

  static bool _containsDangerousCharacters(String value) {
    final dangerousPatterns = [
      '<script',
      '</script',
      '<iframe',
      '</iframe',
      'javascript:',
      'onerror=',
      'onload=',
      'eval(',
      'expression(',
      '<embed',
      '<object',
      // SQL injection patterns
      "';",
      '";',
      '--',
      '/*',
      '*/',
      'xp_',
      'sp_',
      'DROP TABLE',
      'DROP DATABASE',
      'DELETE FROM',
      'INSERT INTO',
      'UPDATE SET',
    ];

    final lowerValue = value.toLowerCase();
    for (var pattern in dangerousPatterns) {
      if (lowerValue.contains(pattern.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  static final lettersOnly = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-ZÀ-ỹ\s]'),
  );

  static final numbersOnly = FilteringTextInputFormatter.digitsOnly;

  static final decimalOnly = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9.]'),
  );
  static final blockDangerousChars = FilteringTextInputFormatter.deny(
    RegExp(r'[<>{}[\]\\|`]'),
  );

  static final emailFormat = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z0-9@._+-]'),
  );

  static final phoneFormat = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9\s-]'),
  );
}
