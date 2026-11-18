import 'package:flutter/material.dart';

/// GeoMatch merkezi renk paleti.
/// Mavi ağırlıklı, yüksek kontrastlı ve modern yüzey hiyerarşisi sunar.
abstract final class AppColors {
  // Primary Brand Colors (Okyanus & Gökyüzü Mavisi Tonları)
  static const Color primaryLight = Color(0xFF1D4ED8); // Royal Blue
  static const Color primaryDark = Color(0xFF60A5FA);  // Soft Sky Blue
  static const Color primaryContainerLight = Color(0xFFDBEAFE);
  static const Color primaryContainerDark = Color(0xFF1E3A8A);

  // Secondary / Accent Colors (Pusula Turkuazı & Altın Vurgular)
  static const Color secondaryLight = Color(0xFF0284C7);
  static const Color secondaryDark = Color(0xFF38BDF8);
  static const Color accentGold = Color(0xFFF59E0B); // Streak & Başarım Rengi

  // Semantic Feedback Colors (Doğru / Yanlış / Uyarı)
  static const Color successLight = Color(0xFF16A34A);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color successContainerLight = Color(0xFFDCFCE7);
  static const Color successContainerDark = Color(0xFF14532D);

  static const Color errorLight = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFF87171);
  static const Color errorContainerLight = Color(0xFFFEE2E2);
  static const Color errorContainerDark = Color(0xFF7F1D1D);

  // Neutral Surfaces & Backgrounds (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Çok açık soğuk gri
  static const Color surfaceLight = Color(0xFFFFFFFF);    // Saf beyaz kart yüzeyi
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);

  // Neutral Surfaces & Backgrounds (Dark Mode)
  static const Color backgroundDark = Color(0xFF0B1120);  // Derin gece mavisi-siyah
  static const Color surfaceDark = Color(0xFF1E293B);     // Slate kart yüzeyi
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}