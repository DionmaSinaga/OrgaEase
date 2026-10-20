part of 'auth_layout.dart';

/// Isi scroll login: ikon, judul, kartu form.
Widget _layoutBody(
    BuildContext context, ScrollController ctrl, AuthLayout widget) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double w = constraints.maxWidth;
      final double hPad;
      if (w < 360) {
        hPad = 12;
      } else if (w < 480) {
        hPad = 16;
      } else if (w < 800) {
        hPad = 24;
      } else {
        hPad = 32;
      }
      final double titleSize = w < 360 ? 22 : 26;

      return Scrollbar(
        controller: ctrl,
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 48,
              minWidth: constraints.maxWidth,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondaryColor
                                .withValues(alpha: 0.65),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.22),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(widget.icon,
                            size: 32, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 14),
                      _TitleBlock(
                          title: widget.title,
                          subtitle: widget.subtitle,
                          size: titleSize),
                      const SizedBox(height: 24),
                      AuthCard(child: widget.form),
                      const SizedBox(height: 16),
                      Text('© 2026 OrgaEase',
                          style: TextStyle(
                              fontSize: 11.5,
                              color:
                                  Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _TitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final double size;
  const _TitleBlock(
      {required this.title, required this.subtitle, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        const SizedBox(height: 6),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.5,
                color: Colors.white.withValues(alpha: 0.92))),
      ],
    );
  }
}
