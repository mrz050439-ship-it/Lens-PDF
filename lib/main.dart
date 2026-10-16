// ============================================================
// Lens PDF — Single File Flutter Application
// Package: com.lenspdf.app
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class AppColors {
  static const background = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const primary = Color(0xFF253447);
  static const dark = Color(0xFF111820);
  static const textSecondary = Color(0xFF707985);
  static const border = Color(0xFFE1E5EA);
  static const success = Color(0xFF2E7D5B);
  static const error = Color(0xFFC94A4A);

  static const darkBg = Color(0xFF0F151C);
  static const darkSurface = Color(0xFF1A222C);
  static const darkBorder = Color(0xFF2A3644);
}

// ============================================================
// 2) THEME
// ============================================================

class AppTheme {
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
        fontFamily: 'Roboto',
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
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
        indicatorColor: AppColors.primary.withOpacity(0.08),
        elevation: 0,
        height: 68,
        labelTextStyle: MaterialStateProperty.all(
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
        surface: AppColors.darkSurface,
        background: AppColors.darkBg,
        error: AppColors.error,
        onPrimary: AppColors.dark,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
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
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: Colors.white.withOpacity(0.08),
        elevation: 0,
        height: 68,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ============================================================
// 3) STRINGS (Arabic-first, centralized)
// ============================================================

class S {
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
  static const reviewHint = 'اسحب البطاقة لإعادة الترتيب. اضغط للحذف أو التعديل.';
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

  static const settings = 'الإعدادات';
  static const darkMode = 'الوضع الليلي';
  static const about = 'حول التطبيق';
  static const version = 'الإصدار';
  static const aboutBody =
      'Lens PDF هو تطبيق احترافي لمسح المستندات وتحويلها إلى ملفات PDF عالية الجودة.';

  static const cameraPermission = 'صلاحية الكاميرا';
  static const cameraPermissionMsg =
      'يحتاج Lens PDF إلى صلاحية الكاميرا لمسح المستندات.';
  static const openSettings = 'فتح الإعدادات';
  static const ok = 'حسنًا';

  static const confirmDeleteTitle = 'حذف المستند؟';
  static const confirmDeleteBody =
      'هل أنت متأكد من حذف هذا المستند؟ لا يمكن التراجع.';

  static const error = 'حدث خطأ';
  static const successSaved = 'تم الحفظ بنجاح';
  static const renameHint = 'الاسم الجديد';
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
}

enum PageSizeOption { a4, letter }

enum PageOrientation { portrait, landscape }

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
  final f = DateFormat('yyyy/MM/dd HH:mm', 'ar');
  return f.format(d);
}

String defaultFileName() {
  final now = DateTime.now();
  final f = DateFormat('yyyy_MM_dd_HHmm');
  return 'LensPDF_${f.format(now)}';
}

void showSnack(BuildContext ctx, String msg, {bool error = false}) {
  if (!ctx.mounted) return;
  ScaffoldMessenger.of(ctx).showSnackBar(
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

  Future<Directory> _docsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'LensPDF', 'documents'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<DocumentModel>> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    List<DocumentModel> list;
    try {
      final decoded = jsonDecode(raw) as List;
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
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<DocumentModel> saveDocument({
    required String name,
    required Uint8List bytes,
    required int pageCount,
  }) async {
    final dir = await _docsDir();
    final safe = name.replaceAll(RegExp(r'[^\w\u0600-\u06FF\-]'), '_');
    final file = File(p.join(dir.path, '$safe.pdf'));
    final unique = await _uniquePath(file);
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
  /// Applies filter + rotation and writes a processed JPEG to a temp file.
  static Future<File> process(File src, ScanFilter filter, int rotation) async {
    final bytes = await src.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('تعذر قراءة الصورة');
    }

    if (rotation != 0) {
      image = img.copyRotate(image!, angle: rotation);
    }

    switch (filter) {
      case ScanFilter.original:
        break;
      case ScanFilter.auto:
        image = img.adjustColor(image!,
            contrast: 1.12, brightness: 1.05, saturation: 1.02);
        break;
      case ScanFilter.document:
        image = img.adjustColor(image!,
            contrast: 1.25, brightness: 1.08, saturation: 0.85);
        break;
      case ScanFilter.grayscale:
        image = img.grayscale(image!);
        image = img.adjustColor(image!, contrast: 1.15, brightness: 1.02);
        break;
      case ScanFilter.bw:
        image = img.grayscale(image!);
        image = img.adjustColor(image!, contrast: 1.35);
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
    if (image!.width > maxDim || image.height > maxDim) {
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
    final doc = pw.Document();

    PdfPageFormat base;
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
/// A real implementation requires a native image-warp plugin. This service
/// currently returns the input file unchanged; wire it to a plugin later
/// witho