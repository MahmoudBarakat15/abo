import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'transcription_detail_page.dart';

class TranscriptionsPage extends StatefulWidget {
  const TranscriptionsPage({super.key});

  @override
  State<TranscriptionsPage> createState() => _TranscriptionsPageState();
}

class _TranscriptionsPageState extends State<TranscriptionsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;

  List<Map<String, dynamic>> transcriptions = [];
  List<Map<String, dynamic>> filteredTranscriptions = [];
  bool isLoading = true;
  String selectedCategory = 'الكل';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'الكل',
    'منازل السائرين',
    'زاد الغريب',
    'أسباب المحبة',
    'حرس الحدود',
    'عابر سبيل',
  ];

  @override
  void initState() {
    super.initState();
    _loadTranscriptions();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );

    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadTranscriptions() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/transcriptions.json',
      );
      final data = json.decode(response);
      setState(() {
        transcriptions = List<Map<String, dynamic>>.from(data);
        filteredTranscriptions = transcriptions;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('Error loading transcriptions: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterTranscriptions(String query) {
    setState(() {
      filteredTranscriptions = transcriptions.where((item) {
        final matchesCategory =
            selectedCategory == 'الكل' || item['category'] == selectedCategory;
        final matchesQuery =
            query.isEmpty ||
            item['title'].toLowerCase().contains(query.toLowerCase());
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _floatingController.dispose();
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }

  IconData parseIcon(String iconName) {
    switch (iconName) {
      case "star_outlined":
        return Icons.star_outlined;
      case "school_outlined":
        return Icons.school_outlined;
      case "mosque_outlined":
        return Icons.mosque_outlined;
      case "favorite_outlined":
        return Icons.favorite_outlined;
      case "book_outlined":
        return Icons.book_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.0),
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _shimmerController.value * 2, -1.0),
              end: Alignment(1.0 + _shimmerController.value * 2, 1.0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticle(double left, double top, Color color) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Positioned(
          left: left + _floatingAnimation.value,
          top: top + (_floatingAnimation.value * 0.5),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color.withOpacity(0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1B3A),
              Color(0xFF2D1B4E),
              Color(0xFF3A2B5C),
              Color(0xFF4A3B6A),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // الجسيمات المتحركة
            ...List.generate(20, (index) {
              final colors = [
                Color(0xFFFFD700),
                Color(0xFF4CAF50),
                Color(0xFF2196F3),
                Color(0xFF9C27B0),
                Color(0xFFFF5722),
              ];
              return _buildFloatingParticle(
                math.Random().nextDouble() * MediaQuery.of(context).size.width,
                math.Random().nextDouble() * MediaQuery.of(context).size.height,
                colors[math.Random().nextInt(colors.length)],
              );
            }),
            SafeArea(
              child: Column(
                children: [
                  // شريط العنوان المُحسّن
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            child: Stack(
                              children: [
                                // خلفية زجاجية
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 15,
                                      sigmaY: 15,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFFFD700),
                                                  Color(0xFFFFA000),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(
                                                    0xFFFFD700,
                                                  ).withOpacity(0.4),
                                                  blurRadius: 12,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.transcribe_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "التفريغات",
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "الدروس المُفرَّغة",
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 13,
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // تأثير الشيمر
                                Positioned.fill(child: _buildShimmerEffect()),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // شريط البحث والتصفية
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.7),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                // مربع البحث
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.15),
                                        Colors.white.withOpacity(0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: _filterTranscriptions,
                                    textAlign: TextAlign.right,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "ابحث في التفريغات...",
                                      hintStyle: GoogleFonts.cairo(
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(20),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // فئات التصفية
                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    reverse: true,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      final isSelected =
                                          category == selectedCategory;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(
                                            () => selectedCategory = category,
                                          );
                                          _filterTranscriptions(
                                            _searchController.text,
                                          );
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 12,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? LinearGradient(
                                                    colors: [
                                                      Color(0xFFFFD700),
                                                      Color(0xFFFFA000),
                                                    ],
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      Colors.white.withOpacity(
                                                        0.1,
                                                      ),
                                                      Colors.white.withOpacity(
                                                        0.05,
                                                      ),
                                                    ],
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Color(
                                                      0xFFFFD700,
                                                    ).withOpacity(0.8)
                                                  : Colors.white.withOpacity(
                                                      0.2,
                                                    ),
                                              width: 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: Color(
                                                        0xFFFFD700,
                                                      ).withOpacity(0.3),
                                                      blurRadius: 8,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Text(
                                            category,
                                            style: GoogleFonts.cairo(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(
                                                      0.8,
                                                    ),
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // قائمة التفريغات أو مؤشر التحميل
                  if (isLoading)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA000),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFFFD700).withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                                strokeWidth: 4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "جاري تحميل التفريغات...",
                              style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // قائمة التفريغات
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: filteredTranscriptions.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: 64,
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          "لا توجد نتائج",
                                          style: GoogleFonts.cairo(
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    itemCount: filteredTranscriptions.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final transcription =
                                          filteredTranscriptions[index];
                                      final color = parseColor(
                                        transcription["color"],
                                      );
                                      final icon = parseIcon(
                                        transcription["icon"],
                                      );

                                      return Hero(
                                        tag: "transcription_$index",
                                        child: Material(
                                          color: Colors.transparent,
                                          child:
                                              InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        PageRouteBuilder(
                                                          pageBuilder:
                                                              (
                                                                context,
                                                                animation,
                                                                secondaryAnimation,
                                                              ) => TranscriptionDetailPage(
                                                                transcription:
                                                                    transcription,
                                                                color: color,
                                                                heroTag:
                                                                    "transcription_$index",
                                                              ),
                                                          transitionsBuilder:
                                                              (
                                                                context,
                                                                animation,
                                                                secondaryAnimation,
                                                                child,
                                                              ) {
                                                                return SlideTransition(
                                                                  position: animation.drive(
                                                                    Tween(
                                                                      begin:
                                                                          const Offset(
                                                                            1.0,
                                                                            0.0,
                                                                          ),
                                                                      end: Offset
                                                                          .zero,
                                                                    ).chain(
                                                                      CurveTween(
                                                                        curve: Curves
                                                                            .easeInOutCubic,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: child,
                                                                );
                                                              },
                                                        ),
                                                      );
                                                    },
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                20,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              colors: [
                                                                Colors.white
                                                                    .withOpacity(
                                                                      0.15,
                                                                    ),
                                                                Colors.white
                                                                    .withOpacity(
                                                                      0.05,
                                                                    ),
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  25,
                                                                ),
                                                            border: Border.all(
                                                              color: color
                                                                  .withOpacity(
                                                                    0.3,
                                                                  ),
                                                              width: 1,
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: color
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                                blurRadius: 15,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      8,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              // رأس البطاقة
                                                              Row(
                                                                textDirection:
                                                                    TextDirection
                                                                        .rtl,
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                          12,
                                                                        ),
                                                                    decoration: BoxDecoration(
                                                                      gradient: LinearGradient(
                                                                        colors: [
                                                                          color,
                                                                          color.withOpacity(
                                                                            0.8,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            15,
                                                                          ),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: color.withOpacity(
                                                                            0.4,
                                                                          ),
                                                                          blurRadius:
                                                                              8,
                                                                          spreadRadius:
                                                                              1,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Icon(
                                                                      icon,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Text(
                                                                          transcription["title"],
                                                                          style: GoogleFonts.cairo(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.white,
                                                                            height:
                                                                                1.4,
                                                                          ),
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              16,
                                                                        ),
                                                                        // التصنيف فقط
                                                                        Container(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                12,
                                                                            vertical:
                                                                                6,
                                                                          ),
                                                                          decoration: BoxDecoration(
                                                                            color: color.withOpacity(
                                                                              0.2,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                            border: Border.all(
                                                                              color: color.withOpacity(
                                                                                0.4,
                                                                              ),
                                                                              width: 1,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            transcription["category"],
                                                                            style: GoogleFonts.cairo(
                                                                              fontSize: 12,
                                                                              color: color,
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // تأثير الشيمر
                                                        Positioned.fill(
                                                          child:
                                                              _buildShimmerEffect(),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .animate(
                                                    delay: (200 * index).ms,
                                                  )
                                                  .fadeIn(duration: 800.ms)
                                                  .slideY(
                                                    begin: 0.1,
                                                    duration: 800.ms,
                                                    curve: Curves.easeOutExpo,
                                                  )
                                                  .scaleXY(
                                                    begin: 0.9,
                                                    duration: 800.ms,
                                                    curve: Curves.easeOutBack,
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
