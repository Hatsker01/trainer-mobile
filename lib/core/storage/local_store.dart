import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Oddiy JSON fayl xotirasi — sozlamalar (T7), o'qish keshi va davomad
/// outbox'i (T8) uchun.
///
/// DB (sqflite/drift) ATAYIN ishlatilmadi: saqlanadigan narsa — bir nechta
/// kichik JSON blob va qisqa navbat. Ular uchun sxema, migratsiya va yana
/// bitta paket ortiqcha (paket siyosati, D108).
///
/// Yozish **atomik**: avval `.tmp` ga yoziladi, keyin `rename` qilinadi.
/// Aks holda ilova yozish payti o'ldirilsa yarim JSON qoladi va keyingi
/// ochilishda parse xatosi bo'ladi.
class LocalStore {
  LocalStore({Directory? directory}) : _override = directory;

  final Directory? _override;
  Directory? _dir;

  /// Testda vaqtinchalik papka beriladi — `path_provider` platforma
  /// kanaliga muhtoj, unit testda u yo'q.
  Future<Directory> _resolve() async {
    if (_dir != null) {
      return _dir!;
    }
    final Directory base =
        _override ?? await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${base.path}/ustoz');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return _dir = dir;
  }

  File _file(Directory dir, String key) => File('${dir.path}/$key.json');

  /// `null` — fayl yo'q yoki buzilgan (buzilgan bo'lsa o'chiriladi).
  Future<Map<String, dynamic>?> readJson(String key) async {
    try {
      final File file = _file(await _resolve(), key);
      if (!file.existsSync()) {
        return null;
      }
      final Object? decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      // Kutilmagan shakl — keshni tashlaymiz.
      await file.delete();
      return null;
    } on Object {
      // Kesh HECH QACHON ilovani yiqitmaydi — o'qib bo'lmasa kesh yo'q.
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    try {
      final Directory dir = await _resolve();
      final File tmp = File('${dir.path}/$key.tmp');
      await tmp.writeAsString(jsonEncode(value), flush: true);
      await tmp.rename(_file(dir, key).path);
    } on Object {
      // Disk to'la / ruxsat yo'q — kesh yozilmasa ham ilova ishlayveradi.
    }
  }

  Future<void> delete(String key) async {
    try {
      final File file = _file(await _resolve(), key);
      if (file.existsSync()) {
        await file.delete();
      }
    } on Object {
      // e'tiborsiz
    }
  }

  /// Chiqishda (`signOut`) — boshqa trenerning ma'lumoti ko'rinmasin.
  Future<void> clearAll() async {
    try {
      final Directory dir = await _resolve();
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
      _dir = null;
    } on Object {
      // e'tiborsiz
    }
  }
}
