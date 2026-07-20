import 'package:flutter/animation.dart';

/// Harakat egri chiziqlari.
///
/// Dizayn HTML'da ATIGI ikkita maxsus `cubic-bezier` ishlatilgan — qolgani
/// brauzer `ease` (Flutter'da `Curves.ease`). Yangi egri chiziq o'ylab
/// topilmaydi.
abstract final class AppMotion {
  /// Uy egri chizig'i — `cubic-bezier(.2, .8, .2, 1)`.
  ///
  /// Ekran kirishi (`sIn`), ring progressi, grafik ustunlari, toast.
  static const Curve house = Cubic(0.2, 0.8, 0.2, 1);

  /// Sheet egri chizig'i — `cubic-bezier(.2, .9, .25, 1)`.
  ///
  /// FAQAT bottom sheet uchun (dumi biroz tezroq).
  static const Curve sheet = Cubic(0.2, 0.9, 0.25, 1);

  /// Qisqa o'tishlar (chip, tab, tugma, fokus) — CSS default `ease`.
  static const Curve short = Curves.ease;
}
