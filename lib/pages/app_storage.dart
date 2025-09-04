import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AppStorage {
  static late Directory _root;
  static late Directory reelsDir;
  static late Directory videosDir;
  static late Directory imagesDir;
  static late Directory audioDir;

  /// استدعاء هذه الدالة عند تشغيل التطبيق مرة واحدة
  static Future<void> init({String appFolderName = 'MyApp'}) async {
    Directory base;

    if (Platform.isAndroid) {
      // مكان خاص بالتطبيق (آمن ومسموح في Google Play)
      base =
          (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();
    } else {
      // على iOS -> Documents
      base = await getApplicationDocumentsDirectory();
    }

    _root = Directory('${base.path}/$appFolderName');
    if (!await _root.exists()) {
      await _root.create(recursive: true);
    }

    reelsDir = await _ensureDir('Reels');
    videosDir = await _ensureDir('Videos');
    imagesDir = await _ensureDir('Images');
    audioDir = await _ensureDir('Audio');
  }

  static Future<Directory> _ensureDir(String name) async {
    final d = Directory('${_root.path}/$name');
    if (!await d.exists()) {
      await d.create(recursive: true);
    }
    return d;
  }

  /// حفظ ملف بايتات داخل فولدر معين
  static Future<File> saveBytes(
    List<int> bytes, {
    required String subfolder,
    required String fileName,
  }) async {
    late final Directory target;
    switch (subfolder) {
      case 'Reels':
        target = reelsDir;
        break;
      case 'Videos':
        target = videosDir;
        break;
      case 'Images':
        target = imagesDir;
        break;
      case 'Audio':
        target = audioDir;
        break;
      default:
        target = _root;
    }

    final file = File('${target.path}/$fileName');
    return file.writeAsBytes(bytes, flush: true);
  }

  /// المسارات الجاهزة
  static String get rootPath => _root.path;
  static String get reelsPath => reelsDir.path;
  static String get videosPath => videosDir.path;
  static String get imagesPath => imagesDir.path;
  static String get audioPath => audioDir.path;
}
