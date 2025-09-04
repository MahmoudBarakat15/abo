import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BioSection extends StatelessWidget {
  final String title;
  final String content;
  final String imagePath;
  final bool isDarkMode;

  const BioSection({
    super.key,
    required this.title,
    required this.content,
    required this.imagePath,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imagePath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath),
            ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.cairo(
              fontSize: 18, // ✅ تم رفع حجم الخط
              height: 1.6, // ✅ تحسين المسافة بين السطور
              color: textColor,
            ),
            textAlign: TextAlign.justify, // ✅ تم تعديل المحاذاة
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.white24 : Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
