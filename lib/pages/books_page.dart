import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
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
          "https://ia601701.us.archive.org/15/items/noor-book.com-7_202508/Noor-Book.com%20%20%D8%A8%D8%B0%D9%84%20%D8%A7%D9%84%D8%A5%D8%AD%D8%B3%D8%A7%D9%86%20%D8%A8%D8%AA%D9%82%D8%B1%D9%8A%D8%A8%20%D8%B3%D9%86%D9%86%20%D8%A7%D9%84%D9%86%D8%B3%D8%A7%D8%A6%D9%8A%20%D8%A3%D8%A8%D9%8A%20%D8%B9%D8%A8%D8%AF%D8%A7%D9%84%D8%B1%D8%AD%D9%85%D9%86%20%D9%86%D8%B3%D8%AE%D8%A9%20%D9%85%D8%B5%D9%88%D8%B1%D8%A9%207%20.pdf",
      "cover": "assets/72.png",
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
      backgroundColor: const Color(0xFFF4E1D2),
      appBar: AppBar(
        title: Text(
          "📚 الــكــتــب",
          style: GoogleFonts.ibmPlexSansArabic(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown.withOpacity(0.9),
        elevation: 0,
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
                                        color: const Color(0xFFFFD700),
                                        width: 2,
                                      )
                                    : null,
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
                          icon: const Icon(Icons.download),
                          label: const Text("تنزيل الكتاب"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
      backgroundColor: const Color(0xFFF4E1D2),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: pdfController),
    );
  }
}
