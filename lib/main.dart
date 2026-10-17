// ============================================================
// Lens PDF — Single File Flutter Application
// Package: com.lenspdf.app
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// 1) COLORS
// ============================================================

abstract final class AppColors {
  static const background = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF253447);
  static const dark = Color(0xFF111820);
  static const textSecondary = Color(0xFF707985);
  static const border = Color(0xFFE1E5EA);
  static const success = Color(0xFF2E7D5B);
  static const error = Color(0xFFC94A4A);
}

// ============================================================
// 2) THEME
// ============================================================

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.dark,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.dark,
        displayColor: AppColors.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.dark,
        titleTextStyle: TextStyle(
          color: AppColors.dark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dark,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.08),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF8FA3BF),
        surface: Color(0xFF1A222C),
        background: Color(0xFF0F151C),
        error: AppColors.error,
        onPrimary: Color(0xFF0F151C),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F151C),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F151C),
        elevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A222C),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF2A3644)),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A222C),
        indicatorColor: Colors.white.withValues(alpha: 0.08),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A3644),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ============================================================
// 3) STRINGS (Arabic-first, centralized)
// ============================================================

abstract final class S {
  static const appName = 'Lens PDF';
  static const tagline = 'مستنداتك، بشكل أبسط';

  static const navHome = 'الرئيسية';
  static const navScan = 'المسح';
  static const navDocs = 'المستندات';
  static const navSettings = 'الإعدادات';

  static const heroTitle = 'حوّل الورق إلى PDF';
  static const heroSubtitle =
      'امسح مستنداتك وحسّنها واحفظها كملفات PDF عالية الجودة.';
  static const startScan = 'ابدأ المسح';
  static const quickTools = 'أدوات سريعة';
  static const scanDoc = 'مسح مستند';
  static const importImages = 'استيراد من الصور';
  static const ocr = 'OCR';
  static const createPdf = 'إنشاء PDF';
  static const recentDocs = 'آخر المستندات';
  static const viewAll = 'عرض الكل';

  static const noDocs = 'لا توجد مستندات بعد';
  static const noDocsHint = 'ابدأ بمسح أول مستند لك.';

  static const capture = 'التقاط';
  static const gallery = 'المعرض';
  static const done = 'تم';
  static const page = 'صفحة';
  static const pages = 'صفحات';
  static const noCamera = 'لا يمكن الوصول للكاميرا';

  static const edit = 'تعديل';
  static const original = 'الأصلي';
  static const auto = 'تلقائي';
  static const document = 'مستند';
  static const grayscale = 'رمادي';
  static const bw = 'أبيض وأسود';
  static const rotate = 'تدوير';
  static const confirm = 'تأكيد';
  static const cancel = 'إلغاء';
  static const retake = 'إعادة التصوير';
  static const processing = 'جاري تحسين الصورة...';

  static const review = 'مراجعة المستند';
  static const reviewHint =
      'اسحب البطاقة لإعادة الترتيب. اضغط للحذف أو التعديل.';
  static const addPage = 'إضافة صفحة';
  static const createPdfBtn = 'إنشاء PDF';
  static const deletePage = 'حذف الصفحة؟';
  static const deletePageBody = 'هل تريد حذف هذه الصفحة من المستند؟';

  static const pdfOptions = 'خيارات PDF';
  static const fileName = 'اسم الملف';
  static const pageSize = 'حجم الصفحة';
  static const orientation = 'الاتجاه';
  static const portrait = 'عمودي';
  static const landscape = 'أفقي';
  static const save = 'حفظ';
  static const share = 'مشاركة';
  static const print = 'طباعة';
  static const delete = 'حذف';
  static const rename = 'إعادة تسمية';
  static const open = 'فتح';
  static const generating = 'جاري إنشاء PDF...';

  static const search = 'ابحث بالاسم...';
  static const sortBy = 'ترتيب حسب';
  static const newest = 'الأحدث';
  static const oldest = 'الأقدم';
  static const byName = 'الاسم';
  static const bySize = 'الحجم';

  static const settingsTitle = 'الإعدادات';
  static const darkMode = 'الوضع الليلي';
  static const about = 'حول التطبيق';
  static const version = 'الإصدار';
  static const aboutBody =
      'Lens PDF هو تطبيق احترافي لمسح المستندات وتحويلها إلى ملفات PDF عالية الجودة.';

  static const cameraPermission = 'صلاحية الكاميرا';
  static const cameraPermissionMsg =
      'يحتاج Lens PDF إلى صلاحية الكاميرا لمسح المستندات.';
  static const openSettings = 'فتح الإعدادات';

  static const confirmDeleteTitle = 'حذف المستند؟';
  static const confirmDeleteBody =
      'هل أنت متأكد من حذف هذا المستند؟ لا يمكن التراجع.';

  static const error = 'حدث خطأ';
  static const successSaved = 'تم الحفظ بنجاح';
  static const renameHint = 'الاسم الجديد';
  static const retry = 'إعادة المحاولة';
  static const placeDocInFrame = 'ضع المستند داخل الإطار';
  static const noPages = 'لا توجد صفحات';
  static const fileNameRequired = 'اسم الملف مطلوب';
}

// ============================================================
// 4) ENUMS & MODELS
// ============================================================

enum ScanFilter { original, auto, document, grayscale, bw }

extension ScanFilterX on ScanFilter {
  String get label {
    switch (this) {
      case ScanFilter.original:
        return S.original;
      case ScanFilter.auto:
        return S.auto;
      case ScanFilter.document:
        return S.document;
      case ScanFilter.grayscale:
        return S.grayscale;
      case ScanFilter.bw:
        return S.bw;
    }
  }

  IconData get icon {
    switch (this) {
      case ScanFilter.original:
        return Icons.image_outlined;
      case ScanFilter.auto:
        return Icons.auto_fix_high_outlined;
      case ScanFilter.document:
        return Icons.description_outlined;
      case ScanFilter.grayscale:
        return Icons.gradient_outlined;
      case ScanFilter.bw:
        return Icons.contrast_rounded;
    }
  }
}

enum PageSizeOption { a4, letter }

enum PageOrientation { portrait, landscape }

enum DocSort { newest, oldest, byName, bySize }

enum ScanFlowResult { saved, cancelled }

class ScanPage {
  final String id;
  final File file;
  final ScanFilter filter;
  final int rotation;

  ScanPage({
    required this.id,
    required this.file,
    this.filter = ScanFilter.original,
    this.rotation = 0,
  });

  ScanPage copyWith({File? file, ScanFilter? filter, int? rotation}) {
    return ScanPage(
      id: id,
      file: file ?? this.file,
      filter: filter ?? this.filter,
      rotation: rotation ?? this.rotation,
    );
  }
}

class DocumentModel {
  final String id;
  final String name;
  final String path;
  final int size;
  final int pageCount;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.pageCount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'size': size,
        'pageCount': pageCount,
        'createdAt': createdAt.toIso8601String(),
      };

  static DocumentModel fromJson(Map<String, dynamic> j) => DocumentModel(
        id: j['id'] as String,
        name: j['name'] as String,
        path: j['path'] as String,
        size: j['size'] as int,
        pageCount: j['pageCount'] as int,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  DocumentModel copyWith({String? name, String? path, int? size}) =>
      DocumentModel(
        id: id,
        name: name ?? this.name,
        path: path ?? this.path,
        size: size ?? this.size,
        pageCount: pageCount,
        createdAt: createdAt,
      );
}

// ============================================================
// 5) UTILS
// ============================================================

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

String formatDate(DateTime d) {
  final f = DateFormat('yyyy/MM/dd HH:mm');
  return f.format(d);
}

String defaultFileName() {
  final now = DateTime.now();
  final f = DateFormat('yyyy_MM_dd_HHmm');
  return 'LensPDF_${f.format(now)}';
}

void showSnack(BuildContext ctx, String msg, {bool error = false}) {
  if (!ctx.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(ctx);
  if (messenger == null) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}

// ============================================================
// 6) SERVICES
// ============================================================

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  static const _key = 'lens_pdf_docs_v1';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<Directory> _docsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'LensPDF', 'documents'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<DocumentModel>> getDocuments() async {
    final raw = await _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    List<DocumentModel> list;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      list = decoded
          .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }

    final existing = <DocumentModel>[];
    for (final d in list) {
      if (await File(d.path).exists()) existing.add(d);
    }
    if (existing.length != list.length) {
      await _save(existing);
    }
    return existing;
  }

  Future<void> _save(List<DocumentModel> list) async {
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_key, raw);
  }

  Future<DocumentModel> saveDocument({
    required String name,
    required Uint8List bytes,
    required int pageCount,
  }) async {
    final dir = await _docsDir();
    final safe = name.replaceAll(RegExp(r'[^\w\u0600-\u06FF\-]'), '_');
    final target = File(p.join(dir.path, '$safe.pdf'));
    final unique = await _uniquePath(target);
    await unique.writeAsBytes(bytes);

    final doc = DocumentModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: p.basenameWithoutExtension(unique.path),
      path: unique.path,
      size: bytes.length,
      pageCount: pageCount,
      createdAt: DateTime.now(),
    );

    final list = await getDocuments();
    list.insert(0, doc);
    await _save(list);
    return doc;
  }

  Future<File> _uniquePath(File f) async {
    if (!await f.exists()) return f;
    final dir = f.parent.path;
    final base = p.basenameWithoutExtension(f.path);
    final ext = p.extension(f.path);
    var i = 1;
    while (true) {
      final candidate = File(p.join(dir, '${base}_$i$ext'));
      if (!await candidate.exists()) return candidate;
      i++;
    }
  }

  Future<void> deleteDocument(String id) async {
    final list = await getDocuments();
    final idx = list.indexWhere((d) => d.id == id);
    if (idx < 0) return;
    final doc = list[idx];
    final f = File(doc.path);
    if (await f.exists()) await f.delete();
    list.removeAt(idx);
    await _save(list);
  }

  Future<void> renameDocument(String id, String newName) async {
    final list = await getDocuments();
    final idx = list.indexWhere((d) => d.id == id);
    if (idx < 0) return;
    final old = list[idx];
    final dir = await _docsDir();
    final safe = newName.replaceAll(RegExp(r'[^\w\u0600-\u06FF\-]'), '_');
    final newFile = File(p.join(dir.path, '$safe.pdf'));

    if (newFile.path != old.path) {
      final oldFile = File(old.path);
      if (await oldFile.exists()) {
        final target = await _uniquePath(newFile);
        await oldFile.rename(target.path);
        list[idx] = old.copyWith(
          name: p.basenameWithoutExtension(target.path),
          path: target.path,
        );
      }
    } else {
      list[idx] = old.copyWith(name: newName);
    }
    await _save(list);
  }
}

class ImageProcessor {
  static Future<File> process(
    File src,
    ScanFilter filter,
    int rotation,
  ) async {
    final bytes = await src.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('تعذر قراءة الصورة');
    }

    if (rotation != 0) {
      image = img.copyRotate(image, angle: rotation);
    }

    switch (filter) {
      case ScanFilter.original:
        break;
      case ScanFilter.auto:
        image = img.adjustColor(
          image,
          contrast: 1.12,
          brightness: 1.05,
          saturation: 1.02,
        );
        break;
      case ScanFilter.document:
        image = img.adjustColor(
          image,
          contrast: 1.25,
          brightness: 1.08,
          saturation: 0.85,
        );
        break;
      case ScanFilter.grayscale:
        image = img.grayscale(image);
        image = img.adjustColor(image, contrast: 1.15, brightness: 1.02);
        break;
      case ScanFilter.bw:
        image = img.grayscale(image);
        image = img.adjustColor(image, contrast: 1.35);
        for (var y = 0; y < image.height; y++) {
          for (var x = 0; x < image.width; x++) {
            final px = image.getPixel(x, y);
            final lum = px.luminance;
            final v = lum > 140 ? 255 : 0;
            px.setRgb(v, v, v);
          }
        }
        break;
    }

    const maxDim = 2200;
    if (image.width > maxDim || image.height > maxDim) {
      if (image.width >= image.height) {
        image = img.copyResize(image, width: maxDim);
      } else {
        image = img.copyResize(image, height: maxDim);
      }
    }

    final out = img.encodeJpg(image, quality: 88);
    final dir = await getTemporaryDirectory();
    final outFile = File(p.join(
      dir.path,
      'lenspdf_${DateTime.now().microsecondsSinceEpoch}.jpg',
    ));
    await outFile.writeAsBytes(out);
    return outFile;
  }
}

class PdfService {
  static Future<Uint8List> buildPdf({
    required List<File> pages,
    required PageSizeOption size,
    required PageOrientation orientation,
  }) async {
    if (pages.isEmpty) {
      throw Exception('لا توجد صفحات لإنشاء PDF');
    }

    final doc = pw.Document();

    final PdfPageFormat base;
    switch (size) {
      case PageSizeOption.a4:
        base = PdfPageFormat.a4;
        break;
      case PageSizeOption.letter:
        base = PdfPageFormat.letter;
        break;
    }

    final format = orientation == PageOrientation.landscape
        ? base.landscape
        : base;

    for (final f in pages) {
      final bytes = await f.readAsBytes();
      final memImage = pw.MemoryImage(bytes);
      doc.addPage(
        pw.Page(
          pageFormat: format,
          build: (ctx) => pw.Center(
            child: pw.Image(memImage, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    return doc.save();
  }
}

/// Extension point for perspective correction.
/// A real implementation requires a native image-warp plugin (e.g. OpenCV
/// bindings). This service currently returns the input file unchanged.
class DocumentPerspectiveService {
  static Future<File> correct(File src, List<Offset> corners) async {
    return src;
  }
}

/// Extension point for OCR.
/// A real implementation requires `google_mlkit_text_recognition` with
/// language models configured in the Android/iOS project.
class OcrService {
  static Future<String> extractText(File image) async {
    throw UnsupportedError(
      'OCR غير مُفعَّل. أضف google_mlkit_text_recognition '
      'وأكمل تهيئة النماذج في Android/iOS ثم اربطها هنا.',
    );
  }
}

// ============================================================
// 7) MAIN APP
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LensPdfApp());
}

class LensPdfApp extends StatefulWidget {
  const LensPdfApp({super.key});

  @override
  State<LensPdfApp> createState() => _LensPdfAppState();
}

class _LensPdfAppState extends State<LensPdfApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _prefs.getBool('dark_mode') ?? false;
    if (!mounted) return;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _toggleDark(bool v) async {
    await _prefs.setBool('dark_mode', v);
    if (!mounted) return;
    setState(() => _themeMode = v ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: MainShell(
        isDark: _themeMode == ThemeMode.dark,
        onToggleDark: _toggleDark,
      ),
    );
  }
}

// ============================================================
// 8) MAIN SHELL (Bottom Navigation + IndexedStack)
// ============================================================

class MainShell extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onToggleDark;

  const MainShell({
    super.key,
    required this.isDark,
    required this.onToggleDark,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final GlobalKey<DocumentsScreenState> _docsKey =
      GlobalKey<DocumentsScreenState>();

  void _goToDocuments() {
    setState(() => _index = 2);
    _docsKey.currentState?.refresh();
  }

  void _goToScanner() {
    setState(() => _index = 1);
  }

  Future<void> _handleScanDone(List<ScanPage> pages) async {
    if (pages.isEmpty) return;
    final result = await Navigator.of(context).push<ScanFlowResult>(
      MaterialPageRoute(
        builder: (_) => ReviewScreen(pages: pages),
      ),
    );
    if (result == ScanFlowResult.saved) {
      _goToDocuments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            onStartScan: _goToScanner,
            onOpenDocuments: _goToDocuments,
          ),
          ScannerScreen(onDone: _handleScanDone),
          DocumentsScreen(key: _docsKey),
          SettingsScreen(
            isDark: widget.isDark,
            onToggleDark: widget.onToggleDark,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: S.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner_rounded),
            label: S.navScan,
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: S.navDocs,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: S.navSettings,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 9) HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  final VoidCallback onStartScan;
  final VoidCallback onOpenDocuments;

  const HomeScreen({
    super.key,
    required this.onStartScan,
    required this.onOpenDocuments,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentModel> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final docs = await StorageService.instance.getDocuments();
    if (!mounted) return;
    setState(() {
      _recent = docs.take(4).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _header(),
            const SizedBox(height: 20),
            _heroCard(),
            const SizedBox(height: 24),
            _sectionTitle(S.quickTools),
            const SizedBox(height: 12),
            _quickGrid(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle(S.recentDocs),
                if (_recent.isNotEmpty)
                  TextButton(
                    onPressed: widget.onOpenDocuments,
                    child: const Text(S.viewAll),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_recent.isEmpty)
              _emptyDocs()
            else
              ..._recent.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _documentTile(d),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.document_scanner_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                S.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              Text(
                S.tagline,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_motion_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  S.heroTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            S.heroSubtitle,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: widget.onStartScan,
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(S.startScan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
      );

  Widget _quickGrid() {
    final items = <_QuickItem>[
      _QuickItem(
        Icons.document_scanner_outlined,
        S.scanDoc,
        widget.onStartScan,
      ),
      _QuickItem(
        Icons.photo_library_outlined,
        S.importImages,
        widget.onStartScan,
      ),
      _QuickItem(
        Icons.text_fields_rounded,
        S.ocr,
        widget.onStartScan,
      ),
      _QuickItem(
        Icons.picture_as_pdf_outlined,
        S.createPdf,
        widget.onStartScan,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: items.map((it) {
        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: it.onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(it.icon, color: AppColors.primary, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    it.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyDocs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              size: 30,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            S.noDocs,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            S.noDocsHint,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: widget.onStartScan,
            icon: const Icon(Icons.camera_alt_rounded, size: 18),
            label: const Text(S.startScan),
          ),
        ],
      ),
    );
  }

  Widget _documentTile(DocumentModel d) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFBEAEA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${d.pageCount} ${S.pages} · ${formatBytes(d.size)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: S.open,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            color: AppColors.textSecondary,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewScreen(
                    file: File(d.path),
                    title: d.name,
                    documentId: d.id,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _QuickItem(this.icon, this.label, this.onTap);
}

// ============================================================
// 10) SCANNER SCREEN
// ============================================================

class ScannerScreen extends StatefulWidget {
  final void Function(List<ScanPage> pages) onDone;

  const ScannerScreen({super.key, required this.onDone});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _initializing = true;
  bool _hasError = false;
  String _errorMsg = '';
  FlashMode _flash = FlashMode.off;
  final List<ScanPage> _pages = [];
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final old = _controller;
    _controller = null;
    if (old != null) {
      try {
        await old.dispose();
      } catch (_) {}
    }

    final perm = await Permission.camera.request();
    if (!perm.isGranted) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _hasError = true;
        _errorMsg = S.cameraPermissionMsg;
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception(S.noCamera);
      }
      final back = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      final ctrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      setState(() {
        _controller = ctrl;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _hasError = true;
        _errorMsg = '$e';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final ctrl = _controller;
    _controller = null;
    ctrl?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller = null;
      ctrl.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _init();
    }
  }

  Future<void> _toggleFlash() async {
    final ctrl = _controller;
    if (ctrl == null) return;
    try {
      final next = _flash == FlashMode.off ? FlashMode.torch : FlashMode.off;
      await ctrl.setFlashMode(next);
      if (!mounted) return;
      setState(() => _flash = next);
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    }
  }

  Future<void> _capture() async {
    final ctrl = _controller;
    if (ctrl == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final shot = await ctrl.takePicture();
      final page = ScanPage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        file: File(shot.path),
      );
      if (!mounted) return;
      final edited = await Navigator.of(context).push<ScanPage>(
        MaterialPageRoute(builder: (_) => EditScreen(page: page)),
      );
      if (!mounted) return;
      if (edited != null) {
        setState(() => _pages.add(edited));
      }
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      if (!mounted) return;
      final page = ScanPage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        file: File(picked.path),
      );
      final edited = await Navigator.of(context).push<ScanPage>(
        MaterialPageRoute(builder: (_) => EditScreen(page: page)),
      );
      if (edited != null && mounted) {
        setState(() => _pages.add(edited));
      }
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    }
  }

  void _finish() {
    if (_pages.isEmpty) return;
    widget.onDone(List.of(_pages));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) return _errorView();
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Column(
        children: [
          _scannerTopBar(),
          Expanded(child: _cameraPreview(ctrl)),
          _scannerBottomBar(),
        ],
      ),
    );
  }

  Widget _scannerTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _circleBtn(
            icon: _flash == FlashMode.off
                ? Icons.flash_off_rounded
                : Icons.flash_on_rounded,
            onTap: _toggleFlash,
            tooltip: 'Flash',
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.layers_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_pages.length} ${S.page}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _circleBtn(
            icon: Icons.photo_library_outlined,
            onTap: _pickFromGallery,
            tooltip: S.gallery,
          ),
        ],
      ),
    );
  }

  Widget _cameraPreview(CameraController ctrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: CameraPreview(ctrl)),
          IgnorePointer(
            child: CustomPaint(painter: _GuideFramePainter()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  S.placeDocInFrame,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scannerBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _finish,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text('${S.done} (${_pages.length})'),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _capturing ? null : _capture,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: _capturing
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _pages.isEmpty
                  ? null
                  : () => widget.onDone(List.of(_pages)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text(S.review),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.dark, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              S.cameraPermission,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text(S.openSettings),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _initializing = true;
                });
                _init();
              },
              child: const Text(S.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final insetX = size.width * 0.08;
    final insetY = size.height * 0.10;
    final rect = Rect.fromLTRB(
      insetX,
      insetY,
      size.width - insetX,
      size.height - insetY,
    );

    final bg = Paint()..color = Colors.black.withValues(alpha: 0.25);
    final full = Path()..addRect(Offset.zero & size);
    final cut = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      );
    final diff = Path.combine(PathOperation.difference, full, cut);
    canvas.drawPath(diff, bg);

    final border = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(18));
    canvas.drawRRect(rr, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// 11) EDIT SCREEN
// ============================================================

class EditScreen extends StatefulWidget {
  final ScanPage page;

  const EditScreen({super.key, required this.page});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late ScanFilter _filter;
  late int _rotation;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _filter = widget.page.filter;
    _rotation = widget.page.rotation;
  }

  Future<void> _applyAndConfirm() async {
    setState(() => _processing = true);
    try {
      final out = await ImageProcessor.process(
        widget.page.file,
        _filter,
        _rotation,
      );
      if (!mounted) return;
      final page = widget.page.copyWith(
        file: out,
        filter: _filter,
        rotation: _rotation,
      );
      Navigator.of(context).pop(page);
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      showSnack(context, '$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.edit),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _processing ? null : _applyAndConfirm,
            child: const Text(
              S.confirm,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: RotatedBox(
                          quarterTurns: (_rotation ~/ 90) % 4,
                          child: Image.file(
                            widget.page.file,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
                    if (_processing)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              SizedBox(height: 12),
                              Text(
                                S.processing,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            _filterBar(),
            const SizedBox(height: 8),
            _toolsBar(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _filterBar() {
    final filters = ScanFilter.values;
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final f = filters[i];
          final active = f == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    f.icon,
                    color: active ? Colors.white : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _toolsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => _rotation = (_rotation + 90) % 360);
              },
              icon: const Icon(
                Icons.rotate_90_degrees_cw_outlined,
                size: 18,
              ),
              label: const Text(S.rotate),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(S.retake),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 12) REVIEW SCREEN
// ============================================================

class ReviewScreen extends StatefulWidget {
  final List<ScanPage> pages;

  const ReviewScreen({super.key, required this.pages});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late List<ScanPage> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List.of(widget.pages);
  }

  Future<void> _confirmDelete(int index) async {
    final c = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(S.deletePage),
        content: const Text(S.deletePageBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(S.delete),
          ),
        ],
      ),
    );
    if (c == true && mounted) {
      setState(() => _pages.removeAt(index));
    }
  }

  Future<void> _editPage(int index) async {
    final edited = await Navigator.of(context).push<ScanPage>(
      MaterialPageRoute(builder: (_) => EditScreen(page: _pages[index])),
    );
    if (edited != null && mounted) {
      setState(() => _pages[index] = edited);
    }
  }

  Future<void> _openPdfOptions() async {
    if (_pages.isEmpty) {
      showSnack(context, S.noPages, error: true);
      return;
    }

    final options = await showModalBottomSheet<_PdfOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => _PdfOptionsSheet(
        messenger: ScaffoldMessenger.of(context),
      ),
    );
    if (options == null || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _LoadingDialog(text: S.generating),
    );

    try {
      final files = _pages.map((p) => p.file).toList();
      final bytes = await PdfService.buildPdf(
        pages: files,
        size: options.size,
        orientation: options.orientation,
      );
      if (!mounted) return;

      final saved = await StorageService.instance.saveDocument(
        name: options.fileName,
        bytes: bytes,
        pageCount: files.length,
      );
      if (!mounted) return;

      Navigator.of(context).pop();
      showSnack(context, S.successSaved);

      await Navigator.of(context).push<ScanFlowResult>(
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            file: File(saved.path),
            title: saved.name,
            documentId: saved.id,
          ),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(ScanFlowResult.saved);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      showSnack(context, '$e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.review),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      S.reviewHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${_pages.length} ${S.pages}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _pages.isEmpty
                  ? const Center(
                      child: Text(
                        S.noPages,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _pages.length,
                      onReorder: (a, b) {
                        setState(() {
                          if (b > a) b -= 1;
                          final item = _pages.removeAt(a);
                          _pages.insert(b, item);
                        });
                      },
                      itemBuilder: (_, i) {
                        final page = _pages[i];
                        return Padding(
                          key: ValueKey(page.id),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.file(
                                    page.file,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${S.page} ${i + 1}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        page.filter.label,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: S.edit,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () => _editPage(i),
                                ),
                                IconButton(
                                  tooltip: S.delete,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _confirmDelete(i),
                                ),
                                ReorderableDragStartListener(
                                  index: i,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Icon(
                                      Icons.drag_indicator_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _pages.isEmpty ? null : _openPdfOptions,
                  icon: const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 20,
                  ),
                  label: const Text(S.createPdfBtn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfOptions {
  final String fileName;
  final PageSizeOption size;
  final PageOrientation orientation;

  _PdfOptions(this.fileName, this.size, this.orientation);
}

class _PdfOptionsSheet extends StatefulWidget {
  final ScaffoldMessengerState messenger;

  const _PdfOptionsSheet({required this.messenger});

  @override
  State<_PdfOptionsSheet> createState() => _PdfOptionsSheetState();
}

class _PdfOptionsSheetState extends State<_PdfOptionsSheet> {
  late final TextEditingController _nameCtrl;
  PageSizeOption _size = PageSizeOption.a4;
  PageOrientation _orient = PageOrientation.portrait;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: defaultFileName());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      widget.messenger.showSnackBar(
        SnackBar(
          content: const Text(S.fileNameRequired),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    Navigator.of(context).pop(_PdfOptions(name, _size, _orient));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            S.pdfOptions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            S.fileName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          TextField(controller: _nameCtrl),
          const SizedBox(height: 18),
          const Text(
            S.pageSize,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<PageSizeOption>(
            segments: const [
              ButtonSegment(value: PageSizeOption.a4, label: Text('A4')),
              ButtonSegment(
                value: PageSizeOption.letter,
                label: Text('Letter'),
              ),
            ],
            selected: {_size},
            onSelectionChanged: (s) => setState(() => _size = s.first),
          ),
          const SizedBox(height: 18),
          const Text(
            S.orientation,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<PageOrientation>(
            segments: const [
              ButtonSegment(
                value: PageOrientation.portrait,
                label: Text(S.portrait),
                icon: Icon(Icons.stay_current_portrait_rounded, size: 16),
              ),
              ButtonSegment(
                value: PageOrientation.landscape,
                label: Text(S.landscape),
                icon: Icon(Icons.stay_current_landscape_rounded, size: 16),
              ),
            ],
            selected: {_orient},
            onSelectionChanged: (s) => setState(() => _orient = s.first),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: const Text(S.createPdfBtn),
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDialog extends StatelessWidget {
  final String text;

  const _LoadingDialog({required this.text});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 13) PDF PREVIEW SCREEN
// ============================================================

class PdfPreviewScreen extends StatefulWidget {
  final File file;
  final String title;
  final String? documentId;

  const PdfPreviewScreen({
    super.key,
    required this.file,
    required this.title,
    this.documentId,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late final Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = widget.file.readAsBytes();
  }

  Future<void> _share() async {
    try {
      await Share.shareXFiles(
        [XFile(widget.file.path, mimeType: 'application/pdf')],
        text: widget.title,
      );
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    }
  }

  Future<void> _print() async {
    try {
      final bytes = await _bytesFuture;
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    }
  }

  Future<void> _delete() async {
    if (widget.documentId == null) return;
    final c = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(S.confirmDeleteTitle),
        content: const Text(S.confirmDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(S.delete),
          ),
        ],
      ),
    );
    if (c == true) {
      await StorageService.instance.deleteDocument(widget.documentId!);
      if (!mounted) return;
      Navigator.of(context).pop();
      showSnack(context, S.successSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: S.share,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _share,
          ),
          IconButton(
            tooltip: S.print,
            icon: const Icon(Icons.print_outlined),
            onPressed: _print,
          ),
          if (widget.documentId != null)
            IconButton(
              tooltip: S.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: _bytesFuture,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${S.error}: ${snap.error ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          }
          return PdfPreview(
            build: (_) async => snap.data!,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            allowSharing: false,
            allowPrinting: false,
            initialPageFormat: PdfPageFormat.a4,
          );
        },
      ),
    );
  }
}

// ============================================================
// 14) DOCUMENTS SCREEN
// ============================================================

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => DocumentsScreenState();
}

class DocumentsScreenState extends State<DocumentsScreen> {
  List<DocumentModel> _all = [];
  List<DocumentModel> _filtered = [];
  bool _loading = true;
  String _query = '';
  DocSort _sort = DocSort.newest;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    if (mounted) setState(() => _loading = true);
    final docs = await StorageService.instance.getDocuments();
    if (!mounted) return;
    setState(() {
      _all = docs;
      _loading = false;
      _applyFilterSort();
    });
  }

  void _applyFilterSort() {
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? List.of(_all)
        : _all.where((d) => d.name.toLowerCase().contains(q)).toList();

    switch (_sort) {
      case DocSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DocSort.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case DocSort.byName:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case DocSort.bySize:
        list.sort((a, b) => b.size.compareTo(a.size));
        break;
    }
    _filtered = list;
  }

  Future<void> _rename(DocumentModel d) async {
    final ctrl = TextEditingController(text: d.name);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(S.rename),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: S.renameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim()),
            child: const Text(S.save),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name != null && name.isNotEmpty) {
      await StorageService.instance.renameDocument(d.id, name);
      if (!mounted) return;
      refresh();
    }
  }

  Future<void> _delete(DocumentModel d) async {
    final c = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(S.confirmDeleteTitle),
        content: const Text(S.confirmDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(S.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(S.delete),
          ),
        ],
      ),
    );
    if (c == true) {
      await StorageService.instance.deleteDocument(d.id);
      if (!mounted) return;
      refresh();
    }
  }

  Future<void> _share(DocumentModel d) async {
    try {
      await Share.shareXFiles(
        [XFile(d.path, mimeType: 'application/pdf')],
        text: d.name,
      );
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    }
  }

  void _open(DocumentModel d) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PdfPreviewScreen(
              file: File(d.path),
              title: d.name,
              documentId: d.id,
            ),
          ),
        )
        .then((_) {
      if (mounted) refresh();
    });
  }

  Future<void> _showSortSheet() async {
    final result = await showModalBottomSheet<DocSort>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              S.sortBy,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            _sortTile(S.newest, DocSort.newest),
            _sortTile(S.oldest, DocSort.oldest),
            _sortTile(S.byName, DocSort.byName),
            _sortTile(S.bySize, DocSort.bySize),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _sort = result;
        _applyFilterSort();
      });
    }
  }

  Widget _sortTile(String label, DocSort s) {
    return ListTile(
      title: Text(label),
      trailing: _sort == s
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () => Navigator.of(context).pop(s),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    S.navDocs,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: S.sortBy,
                  onPressed: _showSortSheet,
                  icon: const Icon(Icons.sort_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() {
                _query = v;
                _applyFilterSort();
              }),
              decoration: const InputDecoration(
                hintText: S.search,
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _empty()
                    : RefreshIndicator(
                        onRefresh: refresh,
                        child: ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 4, 20, 32),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _tile(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _empty() {
    return LayoutBuilder(
      builder: (_, cst) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: cst.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.folder_open_outlined,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    S.noDocs,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    S.noDocsHint,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(DocumentModel d) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _open(d),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBEAEA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${d.pageCount} ${S.pages} · '
                      '${formatBytes(d.size)} · '
                      '${formatDate(d.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onSelected: (v) {
                  switch (v) {
                    case 'open':
                      _open(d);
                      break;
                    case 'rename':
                      _rename(d);
                      break;
                    case 'share':
                      _share(d);
                      break;
                    case 'delete':
                      _delete(d);
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'open', child: Text(S.open)),
                  PopupMenuItem(value: 'rename', child: Text(S.rename)),
                  PopupMenuItem(value: 'share', child: Text(S.share)),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      S.delete,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 15) SETTINGS SCREEN
// ============================================================

class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggleDark;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onToggleDark,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Text(
            S.settingsTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 20),
          _card(
            child: SwitchListTile.adaptive(
              value: isDark,
              onChanged: onToggleDark,
              title: const Text(
                S.darkMode,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
              secondary: const Icon(
                Icons.dark_mode_outlined,
                color: AppColors.primary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        S.about,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    S.aboutBody,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${S.version} 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}