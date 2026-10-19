import 'package:flutter/material.dart';

/// Batasan ukuran minimal tampilan agar tidak muncul strip kuning "overflowed".
///
/// - Samakan dengan kunci native di `windows/runner/win32_window.cpp`
///   (`kMinWindowWidth` / `kMinWindowHeight`) supaya perilaku konsisten.
/// - Di Flutter (web / layar split / HP kecil) window tetap BISA lebih kecil
///   dari itu, jadi widget [MinWindowGuard] dipakai sebagai jaring pengaman:
///   konten dijaga di lebar minimal lalu bisa di-scroll horizontal,
///   bukan overflow.
class AppWindow {
  AppWindow._();

  /// Lebar minimal (logical pixel) — di bawah ini native Windows menolak resize.
  static const double minWidth = 400;

  /// Tinggi minimal (logical pixel).
  static const double minHeight = 620;

  /// Breakpoint mode sempit (drawer) di HomePage, harus < [minWidth].
  static const double narrowBreakpoint = 760;
}

/// Jaring pengaman anti-overflow untuk seluruh app.
///
/// Dipasang sekali di [MaterialApp.builder]. Cara kerja:
/// - Kalau lebar layar >= [AppWindow.minWidth]: tampilkan [child] apa adanya.
/// - Kalau lebih kecil (web disempitkan / split-screen / HP mungil):
///   kunci konten di lebar [AppWindow.minWidth] di dalam
///   [SingleChildScrollView] horizontal, sehingga user tinggal geser,
///   bukan melihat pesan "overflowed".
class MinWindowGuard extends StatelessWidget {
  final Widget child;
  const MinWindowGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        // constraints.maxWidth bisa infinite saat di dalam scroll —
        // kalau begitu langsung tampilkan child tanpa guard.
        if (w.isInfinite || w >= AppWindow.minWidth) return child;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: AppWindow.minWidth,
              maxWidth: AppWindow.minWidth,
              minHeight: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 0,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
