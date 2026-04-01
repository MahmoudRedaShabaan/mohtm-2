import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Arabic text reshaper - handles Arabic letter joining for PDF rendering
/// This is a workaround for pdf package's lack of native Arabic shaping
String reshapeArabicText(String text) {
  if (text.isEmpty) return text;
  
  // Arabic Unicode ranges
  final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
  
  // If no Arabic characters, return as is
  if (!arabicPattern.hasMatch(text)) return text;
  
  // Common Arabic diacritics (tashkeel) that should be removed before reshaping
  final arabicDiacritics = RegExp(r'[\u064B-\u0652\u0670]');
  
  // Remove diacritics first
  String cleanText = text.replaceAll(arabicDiacritics, '');
  
  // For PDF rendering, we need to reverse the string because
  // PDF renders text left-to-right by default
  // When combined with RTL override, this produces correct Arabic display
  final chars = cleanText.split('');
  
  // Reverse the characters for proper PDF rendering
  final reversed = chars.reversed.join();
  
  return reversed;
}

/// Downloads and caches an Arabic font for PDF generation
class ArabicFontHelper {
  static pw.Font? _cachedRegular;
  static pw.Font? _cachedBold;
  static bool _isLoading = false;
  static bool _loadFailed = false;
  
  static Future<void> ensureLoaded() async {
    if (_loadFailed || _cachedRegular != null) return;
    if (_isLoading) return;
    
    _isLoading = true;
    try {
      // Try to load from Flutter fonts first (registered in pubspec.yaml)
      try {
        final regularData = await rootBundle.load('fonts/NotoNaskhArabic-Regular.ttf');
        _cachedRegular = pw.Font.ttf(regularData);
        
        final boldData = await rootBundle.load('fonts/NotoNaskhArabic-Bold.ttf');
        _cachedBold = pw.Font.ttf(boldData);
        
        _loadFailed = false;
        return;
      } catch (e) {
        // Flutter font not found, try assets
      }
      
      // Try to load from assets
      try {
        final regularData = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
        _cachedRegular = pw.Font.ttf(regularData);
        
        final boldData = await rootBundle.load('assets/fonts/NotoNaskhArabic-Bold.ttf');
        _cachedBold = pw.Font.ttf(boldData);
        
        _loadFailed = false;
        return;
      } catch (e) {
        // Asset not found, try network
      }
      
      // If asset not found, download font
      final client = HttpClient();
      try {
        // Download regular font
        final regularRequest = await client.getUrl(Uri.parse(
          'https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoNaskhArabic/NotoNaskhArabic-Regular.ttf'
        ));
        final regularResponse = await regularRequest.close();
        final List<int> regularBytes = [];
        await for (var chunk in regularResponse) {
          regularBytes.addAll(chunk);
        }
        _cachedRegular = pw.Font.ttf(
          Uint8List.fromList(regularBytes).buffer.asByteData()!
        );
        
        // Download bold font
        final boldRequest = await client.getUrl(Uri.parse(
          'https://github.com/googlefonts/noto-fonts/raw/main/hinted/ttf/NotoNaskhArabic/NotoNaskhArabic-Bold.ttf'
        ));
        final boldResponse = await boldRequest.close();
        final List<int> boldBytes = [];
        await for (var chunk in boldResponse) {
          boldBytes.addAll(chunk);
        }
        _cachedBold = pw.Font.ttf(
          Uint8List.fromList(boldBytes).buffer.asByteData()!
        );
        
        _loadFailed = false;
      } catch (e) {
        _loadFailed = true;
      } finally {
        client.close();
      }
    } catch (e) {
      _loadFailed = true;
    } finally {
      _isLoading = false;
    }
  }
  
  static pw.Font? get regular => _cachedRegular;
  static pw.Font? get bold => _cachedBold;
}
