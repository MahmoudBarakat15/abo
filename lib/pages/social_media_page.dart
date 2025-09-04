import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({super.key});

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late Animation<double> _particleAnimation;

  // قائمة مواقع التواصل
  final List<SocialMediaItem> socialMediaItems = [
    SocialMediaItem(
      title: 'الموقع الرسمي للشيخ',
      url: 'https://alheweny.me/',
      icon: Icons.language_rounded,
      gradient: [Color(0xFF667eea), Color(0xFF764ba2)],
      description: 'الموقع الرسمي بفضيلة الشيخ أبو إسحاق الحويني',
    ),
    SocialMediaItem(
      title: 'صفحة الفيس بوك',
      url: 'https://www.facebook.com/Alheweny.Official.Page',
      icon: Icons.facebook_rounded,
      gradient: [Color(0xFF3b5998), Color(0xFF192f5d)],
      description: 'الصفحة الرسمية على موقع فيس بوك',
    ),
    SocialMediaItem(
      title: 'قناة اليوتيوب',
      url: 'https://www.youtube.com/c/alhewenytube',
      icon: Icons.play_circle_rounded,
      gradient: [Color(0xFFFF0000), Color(0xFF8b0000)],
      description: 'القناة الرسمية على موقع يوتيوب',
    ),
    SocialMediaItem(
      title: 'حساب تويتر',
      url: 'https://twitter.com/alheweny',
      icon: Icons.alternate_email_rounded,
      gradient: [Color(0xFF1DA1F2), Color(0xFF0ea5e9)],
      description: 'الحساب الرسمي على موقع تويتر',
    ),
    SocialMediaItem(
      title: 'قناة التيليجرام',
      url: 'https://t.me/alheweny',
      icon: Icons.send_rounded,
      gradient: [Color(0xFF0088cc), Color(0xFF0369a1)],
      description: 'القناة الرسمية على تطبيق تيليجرام',
    ),
    SocialMediaItem(
      title: 'حساب إنستجرام',
      url: 'https://instagram.com/alheweny',
      icon: Icons.camera_alt_rounded,
      gradient: [Color(0xFFE4405F), Color(0xFF3F5EFB)],
      description: 'الحساب الرسمي على موقع إنستجرام',
    ),
    SocialMediaItem(
      title: 'سوند كلاود',
      url: 'https://soundcloud.com/alheweny-official',
      icon: Icons.music_note_rounded,
      gradient: [Color(0xFFFF8500), Color(0xFFed8936)],
      description: 'الصفحة الرسمية على سوند كلاود',
    ),
    SocialMediaItem(
      title: 'موقع طريق الاسلام',
      url:
          'https://ar.islamway.net/scholar/32/%D8%A3%D8%A8%D9%88-%D8%A5%D8%B3%D8%AD%D8%A7%D9%82-%D8%A7%D9%84%D8%AD%D9%88%D9%8A%D9%86%D9%8A?__ref=search',
      icon: Icons.mosque_rounded,
      gradient: [Color(0xFF059669), Color(0xFF166534)],
      description: 'حساب الشيخ علي موقع طريق الاسلام',
    ),
    SocialMediaItem(
      title: 'موقع اسلام ويب',
      url: 'https://audio.islamweb.net/audio/index.php?page=lecview&sid=452',
      icon: Icons.web_rounded,
      gradient: [Color(0xFF7c3aed), Color(0xFF581c87)],
      description: 'حساب الشيخ علي موقع اسلام ويب',
    ),
    SocialMediaItem(
      title: 'موقع المكتبة الشاملة',
      url: 'https://shamela.ws/book/7693',
      icon: Icons.menu_book_rounded,
      gradient: [Color(0xFFdc2626), Color(0xFF991b1b)],
      description: 'حساب الشيخ علي موقع المكتبة الشاملة',
    ),
    SocialMediaItem(
      title: 'موقع الطريق الي الله',
      url: 'https://way2allah.com/khotab-audio-17.htm',
      icon: Icons.explore_rounded,
      gradient: [Color(0xFF0891b2), Color(0xFF155e75)],
      description: 'حساب الشيخ علي موقع الطريق الي الله',
    ),
    SocialMediaItem(
      title: 'موقع الشريط الاسلامي',
      url:
          'http://www.islamic-tape.com/2013/11/lessons-Lectures-Speeches-mp3-sheikh-Abu-Ishaq-Al-Alheweny.html',
      icon: Icons.library_music_rounded,
      gradient: [Color(0xFFf59e0b), Color(0xFFb45309)],
      description: 'حساب الشيخ علي موقع الشريط الاسلامي',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_particleController);
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    try {
      HapticFeedback.mediumImpact();
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showErrorSnackBar('تعذر فتح الرابط');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ أثناء فتح الرابط');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'مواقع التواصل الاجتماعي',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: screenSize,
                  painter: ParticlePainter(_particleAnimation.value),
                );
              },
            ),
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
              itemCount: socialMediaItems.length,
              itemBuilder: (context, index) {
                final item = socialMediaItems[index];
                return GestureDetector(
                  onTap: () => _launchURL(item.url),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: item.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: item.gradient.last.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.description,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// SocialMediaItem Model
class SocialMediaItem {
  final String title;
  final String url;
  final IconData icon;
  final List<Color> gradient;
  final String description;

  SocialMediaItem({
    required this.title,
    required this.url,
    required this.icon,
    required this.gradient,
    required this.description,
  });
}

// رسم الجزيئات (خلفية متحركة)
class ParticlePainter extends CustomPainter {
  final double progress;
  final math.Random random = math.Random();

  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    const int particleCount = 40;

    for (int i = 0; i < particleCount; i++) {
      final dx = size.width * random.nextDouble();
      final dy = size.height * random.nextDouble();
      final radius = 1.5 + random.nextDouble() * 2.5;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
