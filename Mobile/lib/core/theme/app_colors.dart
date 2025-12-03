import 'package:flutter/material.dart';

class AppColors {
  // --- BRAND COLOR ---
  static const Color primary = Color(0xFFFF6B4A);
  static const Color secondary = Color(0xFF18181B); 

  // --- GRAY SCALE (Đã tinh chỉnh độ tương phản) ---
  static const Color gray50 = Color(0xFFF9FAFB);  // Nền background cực nhạt
  static const Color gray100 = Color(0xFFF3F4F6); // Nền phụ
  
  // [FIX QUAN TRỌNG]: Tăng độ đậm để viền Input hiện rõ
  static const Color gray200 = Color(0xFFD1D5DB); 
  
  static const Color gray300 = Color(0xFF9CA3AF); // Icon disable
  static const Color gray400 = Color(0xFF6B7280); // Text hint
  static const Color gray500 = Color(0xFF4B5563); // Text phụ
  static const Color gray600 = Color(0xFF374151);
  static const Color gray700 = Color(0xFF1F2937); // Text body
  static const Color gray800 = Color(0xFF111827);
  static const Color gray900 = Color(0xFF030712); // Text heading

  // --- MAPPING (Giữ nguyên tên biến cũ) ---
  static const Color slate50 = gray50;
  static const Color slate100 = gray100;
  static const Color slate200 = gray200; // Border sẽ ăn theo màu này
  static const Color slate300 = gray300;
  static const Color slate400 = gray400;
  static const Color slate500 = gray500; 
  static const Color slate600 = gray600;
  static const Color slate700 = gray700;
  static const Color slate800 = gray800;
  static const Color slate900 = gray900;

  // --- STATUS ---
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // --- SEMANTIC ALIASES ---
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFF09090B);
  static const Color backgroundAlt = gray50;

  static const Color textPrimary = gray900;
  static const Color textSecondary = gray500;
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = gray400;

  // Border: Trỏ về gray200 (màu đã fix đậm hơn)
  static const Color border = gray200;    
  static const Color divider = gray100;
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF18181B);

  static const Color primaryLight = Color(0xFFFFE5DF);
  static const Color primaryDark = Color(0xFFC24125);
}