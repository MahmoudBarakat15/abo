import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Map<String, String>> books = const [
    {
      "title": "0",
      "url":
          "https://ia801209.us.archive.org/22/items/1_20250816_20250816_1903/1.pdf",
      "cover": "assets/58.png",
    },
    {
      "title": "1",
      "url":
          "https://ia801209.us.archive.org/22/items/1_20250816_20250816_1903/1.pdf",
      "cover": "assets/301.png",
    },
    {
      "title": "2",
      "url":
          "https://ia601701.us.archive.org/16/items/2_20250816_20250816_1912/2.pdf",
      "cover": "assets/59.png",
    },
    {
      "title": "3",
      "url":
          "https://ia801007.us.archive.org/20/items/3_20250816_20250816_1915/3.pdf",
      "cover": "assets/60.png",
    },
    {
      "title": "4",
      "url":
          "https://ia601006.us.archive.org/2/items/4_20250816_20250816_1935/4.pdf",
      "cover": "assets/61.png",
    },
    {
      "title": "5",
      "url":
          "https://ia600907.us.archive.org/28/items/5_20250816_20250816_2017/5.pdf",
      "cover": "assets/62.png",
    },
    {
      "title": "6",
      "url":
          "https://ia600900.us.archive.org/5/items/6_20250816_20250816/6.pdf",
      "cover": "assets/63.png",
    },
    {
      "title": "7",
      "url":
          "https://ia600905.us.archive.org/15/items/7_20250816_20250816/7.pdf",
      "cover": "assets/64.png",
    },
    {
      "title": "8",
      "url":
          "https://ia600902.us.archive.org/14/items/8_20250817_20250817/8.pdf",
      "cover": "assets/65.png",
    },
    {
      "title": "9",
      "url":
          "https://ia902909.us.archive.org/4/items/9_20250817_20250817/9.pdf",
      "cover": "assets/66.png",
    },
    {
      "title": "10",
      "url":
          "https://ia600907.us.archive.org/30/items/10_20250817_202508/10.pdf",
      "cover": "assets/67.png",
    },
    {
      "title": "11",
      "url":
          "https://ia601008.us.archive.org/1/items/11_20250817_20250817/11.pdf",
      "cover": "assets/68.png",
    },
    {
      "title": "12",
      "url":
          "https://ia600909.us.archive.org/28/items/12_20250817_20250817_1929/12.pdf",
      "cover": "assets/69.png",
    },
    {
      "title": "13",
      "url":
          "https://ia601701.us.archive.org/0/items/13_20250817_202508/13.pdf",
      "cover": "assets/70.png",
    },
    {
      "title": "14",
      "url":
          "https://ia601009.us.archive.org/1/items/14_20250817_20250817_2003/14.pdf",
      "cover": "assets/71.png",
    },
    {
      "title": "15",
      "url":
          "https://ia601701.us.archive.org/15/items/noor-book.com-7_202508/Noor-Book.com%20%20%D8%A8%D8%B0%D9%84%20%D8%A5%D8%AD%D8%B3%D8%A7%D9%86%20%D8%A8%D8%AA%D9%82%D8%B1%D9%8A%D8%A8%20%D8%B3%D9%86%D9%86%20%D8%A7%D9%84%D9%86%D8%B3%D8%A7%D8%A6%D9%8A%20%D8%A3%D8%A8%D9%8A%20%D8%B9%D8%A8%D8%AF%D8%A7%D9%84%D8%B1%D8%AD%D9%85%D9%86%20%D9%86%D8%B3%D8%AE%D8%A9%20%D9%85%D8%B5%D9%88%D8%B1%D8%A9%207%20.pdf",
      "cover": "assets/72.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _showProgressNotification(int progress, String title) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'download_channel',
          'تنزيل الكتب',
          channelDescription: 'إشعارات تقدم التنزيل',
          importance: Importance.high,
          priority: Priority.high,
          showProgress: true,
          maxProgress: 100,
          onlyAlertOnce: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'جاري تنزيل "$title"',
      '$progress%',
      notificationDetails,
      payload: 'download',
    );
  }

  Future<void> _downloadBook(String url, String title) async {
    try {
      // ✅ لا نطلب إذن تخزين — لأننا نستخدم مجلد التطبيق الداخلي
      final documentsDir = await getApplicationDocumentsDirectory();
      final safeTitle = title.replaceAll(RegExp(r'[\/:*?"<>| ]'), '_');
      final String filePath = "${documentsDir.path}/$safeTitle.pdf";

      _showElegantSnackBar("📥 بدء تحميل الكتاب...");

      final dio = Dio();
      await dio.download(
        url.trim(), // ✅ إصلاح: إزالة المسافات الزائدة من الرابط
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).floor();
            _showProgressNotification(progress, title);
          }
        },
      );

      await flutterLocalNotificationsPlugin.cancel(0);
      _showElegantSnackBar("✅ تم تحميل الكتاب بنجاح");
    } catch (e) {
      print("خطأ في التحميل: $e");
      _showElegantSnackBar("❌ فشل التحميل: تحقق من الرابط أو الاتصال");
    }
  }

  Future<void> _openBook(Map<String, String> book) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final safeTitle = book["title"]!.replaceAll(RegExp(r'[\/:*?"<>| ]'), '_');
      final localFilePath = "${documentsDir.path}/$safeTitle.pdf";
      final file = File(localFilePath);

      String? filePathToUse;

      if (await file.exists()) {
        filePathToUse = localFilePath;
      } else {
        filePathToUse = null; // سيُحمّل من الإنترنت عند الفتح
      }

      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: PdfViewerPage(
            title: book["title"]!,
            localFilePath: filePathToUse,
            pdfUrl: filePathToUse == null ? book["url"]! : null,
          ),
        ),
      );
    } catch (e) {
      print("خطأ في فتح الكتاب: $e");
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: PdfViewerPage(title: book["title"]!, pdfUrl: book["url"]!),
        ),
      );
    }
  }

  void _showElegantSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF2C1810),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0E0A), // أسود بني داكن
              Color(0xFF2C1810), // بني داكن
              Color(0xFF3D2416), // بني متوسط
              Color(0xFF4A2C1A), // بني فاتح
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with luxury design
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFD700), // ذهبي
                            Color(0xFFFFA500), // برتقالي ذهبي
                            Color(0xFFFFD700), // ذهبي
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFF2C1810),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "الكتب",
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C1810),
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.white.withOpacity(0.5),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Books carousel
              Expanded(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double value = 1.0;
                                if (_pageController.hasClients &&
                                    _pageController.position.haveDimensions) {
                                  value = (_pageController.page! - index).abs();
                                }

                                final isFocused = value < 0.3;
                                final scale = isFocused ? 1.0 : 0.85;
                                final opacity = isFocused ? 1.0 : 0.6;

                                return Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          // Book cover container
                                          Expanded(
                                            flex: 4,
                                            child: GestureDetector(
                                              onTap: () => _openBook(book),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(25),
                                                        topRight:
                                                            Radius.circular(25),
                                                      ),
                                                  border: isFocused
                                                      ? Border.all(
                                                          color: const Color(
                                                            0xFFFFD700,
                                                          ),
                                                          width: 2,
                                                        )
                                                      : null,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(22),
                                                        topRight:
                                                            Radius.circular(22),
                                                      ),
                                                  child: Stack(
                                                    children: [
                                                      // Book cover image
                                                      Positioned.fill(
                                                        child: Image.asset(
                                                          book["cover"]!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      // Glossy overlay
                                                      if (isFocused)
                                                        Positioned.fill(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .center,
                                                                colors: [
                                                                  Colors.white
                                                                      .withOpacity(
                                                                        0.2,
                                                                      ),
                                                                  Colors
                                                                      .transparent,
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      // Floating icon
                                                      if (isFocused)
                                                        Positioned(
                                                          top: 15,
                                                          right: 15,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  const Color(
                                                                    0xFFFFD700,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  blurRadius: 8,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        4,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .auto_stories,
                                                              color: Color(
                                                                0xFF2C1810,
                                                              ),
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Download button container
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF2C1810),
                                                  const Color(0xFF1A0E0A),
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                      25,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(25),
                                                  ),
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () => _downloadBook(
                                                  book["url"]!,
                                                  book["title"]!,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFFFFD700,
                                                  ),
                                                  foregroundColor: const Color(
                                                    0xFF2C1810,
                                                  ),
                                                  elevation: 4,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.download_rounded,
                                                      color: Color(0xFF2C1810),
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "تنزيل",
                                                      style:
                                                          GoogleFonts.ibmPlexSansArabic(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: const Color(
                                                              0xFF2C1810,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom page indicator dots
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          (books.length / 5).ceil(),
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String? pdfUrl;
  final String? localFilePath;

  const PdfViewerPage({
    super.key,
    required this.title,
    this.pdfUrl,
    this.localFilePath,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfControllerPinch pdfController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.localFilePath != null) {
      _loadPdfFromFile(widget.localFilePath!);
    } else {
      _loadPdfFromUrl(widget.pdfUrl!);
    }
  }

  Future<void> _loadPdfFromFile(String path) async {
    try {
      pdfController = PdfControllerPinch(document: PdfDocument.openFile(path));
      setState(() => isLoading = false);
    } catch (e) {
      print("❌ فشل فتح الملف المحلي: $e");
      if (widget.pdfUrl != null) {
        _loadPdfFromUrl(widget.pdfUrl!);
      }
    }
  }

  Future<void> _loadPdfFromUrl(String url) async {
    try {
      final response = await Dio().get(
        url.trim(), // ✅ إصلاح الرابط
        options: Options(responseType: ResponseType.bytes),
      );
      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(response.data),
      );
      setState(() => isLoading = false);
    } catch (e) {
      print("❌ خطأ في تحميل الملف من الإنترنت: $e");
      _showSnackBar("فشل تحميل الكتاب، تأكد من الاتصال بالإنترنت");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0E0A), Color(0xFF2C1810)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Luxury AppBar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF2C1810),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C1810),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the back button
                  ],
                ),
              ),

              // PDF Viewer
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: Colors.white,
                      child: isLoading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFFD700),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'جاري تحميل الكتاب...',
                                    style: GoogleFonts.ibmPlexSansArabic(
                                      fontSize: 16,
                                      color: const Color(0xFF2C1810),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : PdfViewPinch(controller: pdfController),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
