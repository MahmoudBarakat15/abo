import 'package:flutter/material.dart';
import 'package:alhouini_library/pages/bio_data.dart' as data;
import 'package:alhouini_library/pages/bio_section.dart' as section;
import 'package:google_fonts/google_fonts.dart';

class FullBioPage extends StatefulWidget {
  const FullBioPage({super.key});

  @override
  State<FullBioPage> createState() => _FullBioPageState();
}

class _FullBioPageState extends State<FullBioPage> {
  final scrollController = ScrollController();
  final List<GlobalKey> sectionKeys = [];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    sectionKeys.addAll(
      List.generate(data.bioSections.length, (_) => GlobalKey()),
    );
  }

  void scrollToSection(int index) {
    final keyContext = sectionKeys[index].currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFFF8DC),
      appBar: AppBar(
        title: Text(
          'السيرة والمسيرة',
          style: GoogleFonts.cairo(
            color: isDark ? const Color(0xFFFFD700) : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFFFD700) : Colors.black,
        ),
      ),
      body: Column(
        children: [
          // ✅ فهرس علوي بشكل شرائح ذهبية أنيقة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(data.bioSections.length, (index) {
                  final sectionData = data.bioSections[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      scrollToSection(index);
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : const Color(0xFFF5F5DC),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Colors.amber
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        sectionData.title,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey[800],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const Divider(),

          // ✅ عرض الأقسام داخل ScrollView
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(data.bioSections.length, (index) {
                  final sectionData = data.bioSections[index];
                  return Container(
                    key: sectionKeys[index],
                    margin: const EdgeInsets.only(bottom: 24),
                    child: section.BioSection(
                      title: sectionData.title,
                      content: sectionData.content,
                      imagePath: sectionData.imagePath,
                      isDarkMode: isDark,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
