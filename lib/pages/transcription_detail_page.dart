import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TranscriptionDetailPage extends StatefulWidget {
  final Map<String, dynamic> transcription;
  final Color color;
  final String heroTag;

  const TranscriptionDetailPage({
    super.key,
    required this.transcription,
    required this.color,
    required this.heroTag,
  });

  @override
  State<TranscriptionDetailPage> createState() =>
      _TranscriptionDetailPageState();
}

class _TranscriptionDetailPageState extends State<TranscriptionDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _shareTranscription() {
    Share.share(
      '${widget.transcription['title']}\n\n${widget.transcription['content']}\n\n---\nتم المشاركة من تطبيق التفريغات',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withOpacity(0.9),
                  widget.color.withOpacity(0.7),
                  widget.color.withOpacity(0.5),
                ],
              ),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // شريط التطبيق المخصص
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: Container(),
                  flexibleSpace: FlexibleSpaceBar(
                    background: AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              // 👇 إضافة هذا السطر لمنع التجاوز
                              constraints: BoxConstraints(maxHeight: 120),
                              padding: const EdgeInsets.only(
                                top: 60,
                                left: 20,
                                right: 20,
                              ),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.transcription['title'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 20, // 👈 تم التصغير من 22
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withOpacity(
                                                  0.4,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: widget.color.withOpacity(
                                              0.3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: widget.color.withOpacity(
                                                0.5,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            widget.transcription['category'],
                                            style: GoogleFonts.cairo(
                                              fontSize:
                                                  12, // 👈 تم التصغير من 14
                                              color: widget.color,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: _shareTranscription,
                    ),
                  ],
                ),

                // محتوى التفريغ
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          widget.transcription['content'],
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            height: 1.8,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
