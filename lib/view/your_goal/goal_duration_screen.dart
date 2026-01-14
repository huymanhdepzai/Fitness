import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'plan_preview_screen.dart';

class GoalDurationScreen extends StatelessWidget {
  static const routeName = "/GoalDurationScreen";
  const GoalDurationScreen({super.key});

  String _goalLabel(String goal) {
    switch (goal.toLowerCase()) {
      case 'lose_fat':
        return 'Giảm mỡ';
      case 'lean_tone':
        return 'Săn chắc';
      case 'improve_shape':
        return 'Cải thiện hình dáng';
      default:
        return goal;
    }
  }

  String _durationSubtitle(int days) {
    if (days == 30) return '1 tháng • Nhẹ nhàng, dễ theo';
    if (days == 60) return '2 tháng • Tiến bộ rõ rệt';
    if (days == 90) return '3 tháng • Thói quen vững chắc';
    final weeks = (days / 7).floor();
    return '$weeks tuần';
  }

  // ✅ Text style dễ đọc trên nền gradient
  TextStyle get _titleWhite => const TextStyle(
    color: Color(0xFFFDFDFD),
    fontSize: 20,
    fontWeight: FontWeight.w900,
    shadows: [
      Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
    ],
  );

  TextStyle get _subWhite => TextStyle(
    color: Colors.white.withOpacity(0.92),
    fontSize: 13,
    fontWeight: FontWeight.w700,
    shadows: const [
      Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
    ],
  );

  Widget _badge({required String text, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goal = ModalRoute.of(context)!.settings.arguments as String;
    final goalText = _goalLabel(goal);

    Widget item({
      required int days,
      required IconData icon,
      bool popular = false,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlanPreviewScreen(goal: goal, durationDays: days),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ✅ tăng opacity cho dễ đọc
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.24)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '',
                          style: TextStyle(),
                        ),
                        Text(
                          '$days ngày',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (popular)
                          _badge(
                            text: 'Phổ biến',
                            bg: Colors.white.withOpacity(0.20),
                            fg: Colors.white,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _durationSubtitle(days),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.95)),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // ===== Background gradient =====
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryG),
          ),
        ),

        // ✅ Dark overlay để chữ nổi rõ hơn
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.22), // chỉnh 0.18~0.28 tuỳ nền
          ),
        ),

        // ===== Content =====
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Thời gian hoàn thành',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('Chọn thời gian mục tiêu', style: _titleWhite),
                // const SizedBox(height: 8),
                Text('Mục tiêu: $goalText', style: _subWhite),
                const SizedBox(height: 14),

                // ===== Quick summary glass card =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.track_changes, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Chọn thời gian phù hợp giúp bạn duy trì thói quen tốt hơn.\n'
                              'Bạn có thể thay đổi kế hoạch sau.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.94),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            shadows: const [
                              Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ===== Options =====
                item(days: 30, icon: Icons.calendar_month_rounded, popular: true),
                item(days: 60, icon: Icons.date_range_rounded),
                item(days: 90, icon: Icons.event_available_rounded),

                const Spacer(),
                // Text(
                //   'Tip: 30 ngày phù hợp để bắt đầu, 60–90 ngày giúp kết quả ổn định hơn.',
                //   style: TextStyle(
                //     color: Colors.white.withOpacity(0.86),
                //     fontSize: 12,
                //     fontWeight: FontWeight.w700,
                //     shadows: const [
                //       Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
