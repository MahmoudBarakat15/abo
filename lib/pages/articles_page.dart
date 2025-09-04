import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final PageController _pageController = PageController(viewportFraction: 0.7);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<Map<String, String>> books = const [
    {
      "title": "1",
      "url":
          "https://ia601209.us.archive.org/22/items/1_20250816_20250816_1903/1.pdf",
      "cover": "assets/58.png",
    },
    {
      "title": "2",
      "url": "https://ia601603.us.archive.org/28/items/a102_20250831/a102.pdf",
      "cover": "assets/301.png",
    },
    {
      "title": "3",
      "url": "https://ia601007.us.archive.org/20/items/a101_20250831/a101.pdf",
      "cover": "assets/300.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
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
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يجب السماح بصلاحية الوصول الكامل للملفات"),
        ),
      );
      return;
    }

    try {
      final List<Directory>? dirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      final Directory downloadsDir = dirs!.first;
      final String filePath = "${downloadsDir.path}/$title.pdf";
      final File file = File(filePath);

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).floor();
            _showProgressNotification(progress, title);
          }
        },
      );

      await flutterLocalNotificationsPlugin.cancel(0);

      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: PdfViewerPage(title: title, localFilePath: filePath),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ فشل التحميل: $e")));
    }
  }

  Future<void> _openBook(Map<String, String> book) async {
    final List<Directory>? dirs = await getExternalStorageDirectories(
      type: StorageDirectory.downloads,
    );
    final Directory downloadsDir = dirs!.first;
    final String filePath = "${downloadsDir.path}/${book["title"]}.pdf";
    final File file = File(filePath);

    final bool fileExists = await file.exists();

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: PdfViewerPage(
          title: book["title"]!,
          localFilePath: fileExists ? filePath : null,
          pdfUrl: fileExists ? null : book["url"]!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F1), // بيج فاتح راقي
      appBar: AppBar(
        title: Text(
          "📚 المقالات",
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3E5C42), // أخضر زيتوني غامق
        elevation: 4,
      ),
      body: Center(
        child: SizedBox(
          height: 500,
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
                  final scale = isFocused ? 1.05 : 0.9;

                  return Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _openBook(book);
                          },
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: isFocused
                                    ? Border.all(
                                        color: const Color(0xFFD4AF37), // ذهبي
                                        width: 2,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  book["cover"]!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _downloadBook(book["url"]!, book["title"]!);
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text("تنزيل المقال"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF3E5C42,
                            ), // أخضر زيتوني
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
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
    pdfController = PdfControllerPinch(document: PdfDocument.openFile(path));
    setState(() => isLoading = false);
  }

  Future<void> _loadPdfFromUrl(String url) async {
    try {
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(response.data),
      );
      setState(() => isLoading = false);
    } catch (e) {
      print("❌ خطأ في تحميل الملف من الإنترنت: $e");
    }
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F1), // بيج فاتح
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3E5C42), // أخضر زيتوني
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: pdfController),
    );
  }
}
