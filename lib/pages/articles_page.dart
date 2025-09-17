import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'article_detail_page.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );
  }

  Future<void> _loadArticles() async {
    final String response = await rootBundle.loadString(
      'assets/data/articles.json',
    );
    final data = json.decode(response);
    setState(() {
      articles = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }

  IconData parseIcon(String iconName) {
    switch (iconName) {
      case "book_outlined":
        return Icons.book_outlined;
      case "water_drop_outlined":
        return Icons.water_drop_outlined;
      case "camera_alt_outlined":
        return Icons.camera_alt_outlined;
      case "home_outlined":
        return Icons.home_outlined;
      case "music_off_outlined":
        return Icons.music_off_outlined;
      case "monetization_on_outlined":
        return Icons.monetization_on_outlined;
      case "flight_outlined":
        return Icons.flight_outlined;
      case "mosque_outlined":
        return Icons.mosque_outlined;
      default:
        return Icons.article_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5D3A8C),
              Color(0xFF7C5BA6),
              Color(0xFF9A80C0),
              Color(0xFFB5A5D8),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // الـ App Bar المُعاد تصميمه
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.12),
                                Colors.white.withOpacity(0.06),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: const Color(0xFFFFF0C0).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFE082),
                                      Color(0xFFFFA726),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.article_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "المقالات",
                                      style: GoogleFonts.cairo(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "بقلم الشيخ الحويني",
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.85),
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // لو لسه بيحمل
              if (isLoading)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                )
              else
                // القائمة المُحسّنة
                Expanded(
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: articles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            final color = parseColor(article["color"]);
                            final icon = parseIcon(article["icon"]);

                            return Hero(
                              tag: "article_${article['id']}",
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ArticleDetailPage(
                                          title: article["title"],
                                          content: article["content"],
                                          color: color,
                                          heroTag: "article_${article['id']}",
                                        ),
                                      ),
                                    );
                                  },
                                  child:
                                      AnimatedContainer(
                                            duration: 300.ms,
                                            curve: Curves.easeOut,
                                            padding: const EdgeInsets.all(26),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(
                                                    0.15,
                                                  ),
                                                  Colors.white.withOpacity(
                                                    0.05,
                                                  ),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                width: 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: color.withOpacity(
                                                    0.25,
                                                  ),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                  spreadRadius: -2,
                                                ),
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: ScaleTransition(
                                              scale: AlwaysStoppedAnimation(
                                                1.0,
                                              ),
                                              child: Row(
                                                textDirection:
                                                    TextDirection.rtl,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          color.withOpacity(
                                                            0.95,
                                                          ),
                                                          color.withOpacity(
                                                            0.75,
                                                          ),
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: color
                                                              .withOpacity(0.5),
                                                          blurRadius: 12,
                                                          offset: const Offset(
                                                            0,
                                                            6,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      icon,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 24),
                                                  Expanded(
                                                    child: Text(
                                                      article["title"],
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 14.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                        height: 1.4,
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .arrow_back_ios_new_rounded,
                                                      color: Colors.white
                                                          .withOpacity(0.85),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .animate(
                                            delay: (300 * index)
                                                .ms, // ✅ التأخير الصحيح هنا
                                          )
                                          .fadeIn(duration: 600.ms)
                                          .slideY(
                                            begin: 0.03,
                                            duration: 600.ms,
                                            curve: Curves.easeOutExpo,
                                          )
                                          .scaleXY(
                                            begin: 0.96,
                                            duration: 600.ms,
                                            curve: Curves.easeOutBack,
                                          ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
