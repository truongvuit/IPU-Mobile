import 'package:flutter/material.dart';

/// Minimalist Design System - 2 Brand Colors + Neutral Scale
/// 
/// Usage Guide:
/// - Primary (Navy Blue): Main interactive elements, links, selections
/// - Secondary (Orange): CTAs, highlights, notifications  
/// - Neutral: Text, borders, backgrounds
/// - Status: Success/Error/Warning for semantic feedback
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS (Core 2 - Based on IPU Logo)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Primary Navy Blue - Main brand color (matches IPU logo)
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFDBEAFE);  // 10% opacity background
  static const Color primaryDark = Color(0xFF1E3A5F);   // Pressed/Dark state
  
  /// Secondary Orange - Accent color for CTAs (matches IPU logo "IPU" text)
  static const Color secondary = Color(0xFFFF6B35);
  static const Color secondaryLight = Color(0xFFFFE5DF);
  static const Color secondaryDark = Color(0xFFC24125);

  // ═══════════════════════════════════════════════════════════════════════════
  // NEUTRAL SCALE (Simplified)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Light backgrounds
  static const Color neutral50 = Color(0xFFF9FAFB);   // Page background light
  static const Color neutral100 = Color(0xFFF3F4F6);  // Card background alt
  static const Color neutral200 = Color(0xFFE5E7EB);  // Border light, dividers
  
  /// Text & Icons (muted)
  static const Color neutral300 = Color(0xFF9CA3AF);  // Placeholder, disabled
  static const Color neutral400 = Color(0xFF6B7280);  // Secondary text, hints
  static const Color neutral500 = Color(0xFF4B5563);  // Body text
  
  /// Dark backgrounds & Primary text
  static const Color neutral600 = Color(0xFF374151);  // Dark mode surface
  static const Color neutral700 = Color(0xFF1F2937);  // Dark mode card
  static const Color neutral800 = Color(0xFF111827);  // Dark mode background
  static const Color neutral900 = Color(0xFF030712);  // Primary text light mode

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS COLORS (Semantic)
  // ═══════════════════════════════════════════════════════════════════════════
  
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC ALIASES (Use these in widgets)
  // ═══════════════════════════════════════════════════════════════════════════
  
  // Backgrounds
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = neutral800;
  static const Color backgroundAlt = neutral50;
  
  // Surfaces (Cards, Modals)
  static const Color surface = Colors.white;
  static const Color surfaceDark = neutral700;
  
  // Text
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral400;
  static const Color textDisabled = neutral300;
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = neutral300;
  
  // Borders & Dividers
  static const Color border = neutral200;
  static const Color borderDark = neutral600;
  static const Color divider = neutral100;
  
  // ═══════════════════════════════════════════════════════════════════════════
  // LEGACY ALIASES (Backward compatibility - will be deprecated)
  // ═══════════════════════════════════════════════════════════════════════════
  
  @Deprecated('Use neutral50 instead')
  static const Color gray50 = neutral50;
  @Deprecated('Use neutral100 instead')
  static const Color gray100 = neutral100;
  @Deprecated('Use neutral200 instead')
  static const Color gray200 = neutral200;
  @Deprecated('Use neutral300 instead')
  static const Color gray300 = neutral300;
  @Deprecated('Use neutral400 instead')
  static const Color gray400 = neutral400;
  @Deprecated('Use neutral500 instead')
  static const Color gray500 = neutral500;
  @Deprecated('Use neutral600 instead')
  static const Color gray600 = neutral600;
  @Deprecated('Use neutral700 instead')
  static const Color gray700 = neutral700;
  @Deprecated('Use neutral800 instead')
  static const Color gray800 = neutral800;
  @Deprecated('Use neutral900 instead')
  static const Color gray900 = neutral900;
  
  // Slate aliases (map to neutral)
  @Deprecated('Use neutral scale instead')
  static const Color slate50 = neutral50;
  @Deprecated('Use neutral scale instead')
  static const Color slate100 = neutral100;
  @Deprecated('Use neutral scale instead')
  static const Color slate200 = neutral200;
  @Deprecated('Use neutral scale instead')
  static const Color slate300 = neutral300;
  @Deprecated('Use neutral scale instead')
  static const Color slate400 = neutral400;
  @Deprecated('Use neutral scale instead')
  static const Color slate500 = neutral500;
  @Deprecated('Use neutral scale instead')
  static const Color slate600 = neutral600;
  @Deprecated('Use neutral scale instead')
  static const Color slate700 = neutral700;
  @Deprecated('Use neutral scale instead')
  static const Color slate800 = neutral800;
  @Deprecated('Use neutral scale instead')
  static const Color slate900 = neutral900;
}