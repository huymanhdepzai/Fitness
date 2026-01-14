import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  int _refreshKey = 0;

  String _fmtTimestamp(Timestamp? ts) {
    if (ts == null) return '--';
    final d = ts.toDate();
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} • ${two(d.hour)}:${two(d.minute)}';
  }

  String _targetLabel(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 'Unknown';
    return t[0].toUpperCase() + t.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.primaryG),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Lịch sử hoạt động',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: user == null
            ? const Center(
          child: Text(
            'Chưa đăng nhập',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        )
            : Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26),
              topRight: Radius.circular(26),
            ),
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            key: ValueKey(_refreshKey),
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('workout_history')
                .orderBy('performedAt', descending: true)
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Lỗi: ${snap.error}'));
              }

              final docs = snap.data?.docs ?? [];

              if (docs.isEmpty) {
                return _EmptyState(
                  onRefresh: () => setState(() => _refreshKey++),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() => _refreshKey++);
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
                        // child: Container(
                        //   padding: const EdgeInsets.all(14),
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(18),
                        //     gradient: LinearGradient(colors: [
                        //       AppColors.primaryColor1.withOpacity(0.12),
                        //       AppColors.primaryColor2.withOpacity(0.08),
                        //     ]),
                        //     border: Border.all(
                        //       color: Colors.black.withOpacity(0.04),
                        //     ),
                        //   ),
                        //   // child: Row(
                        //   //   children: [
                        //   //     Container(
                        //   //       width: 44,
                        //   //       height: 44,
                        //   //       decoration: BoxDecoration(
                        //   //         gradient: LinearGradient(colors: AppColors.primaryG),
                        //   //         borderRadius: BorderRadius.circular(14),
                        //   //       ),
                        //   //       alignment: Alignment.center,
                        //   //       child: const Icon(Icons.auto_graph, color: Colors.white),
                        //   //     ),
                        //   //     const SizedBox(width: 12),
                        //   //     Expanded(
                        //   //       child: Column(
                        //   //         crossAxisAlignment: CrossAxisAlignment.start,
                        //   //         children: [
                        //   //           Text(
                        //   //             "Tổng: ${docs.length} bài đã ghi nhận",
                        //   //             style: TextStyle(
                        //   //               fontSize: 12,
                        //   //               fontWeight: FontWeight.w600,
                        //   //               color: Colors.grey.shade700,
                        //   //             ),
                        //   //           ),
                        //   //         ],
                        //   //       ),
                        //   //     ),
                        //   //   ],
                        //   // ),
                        // ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      sliver: SliverList.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final m = docs[i].data();
                          final name = (m['exerciseName'] ?? '').toString().trim();
                          final target = (m['primaryTarget'] ?? '').toString();
                          final reps = (m['reps'] ?? 0);
                          final sets = (m['sets'] ?? 0);
                          final performedAt = m['performedAt'] as Timestamp?;

                          return _HistoryCard(
                            title: name.isEmpty ? 'Workout' : name,
                            target: _targetLabel(target),
                            sets: sets,
                            reps: reps,
                            timeText: _fmtTimestamp(performedAt),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String target;
  final dynamic sets;
  final dynamic reps;
  final String timeText;

  const _HistoryCard({
    required this.title,
    required this.target,
    required this.sets,
    required this.reps,
    required this.timeText,
  });

  @override
  Widget build(BuildContext context) {
    final isUnknownTarget = target.toLowerCase() == 'unknown';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryG),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.fitness_center, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isUnknownTarget
                            ? Colors.grey.shade100
                            : AppColors.primaryColor1.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isUnknownTarget
                              ? Colors.grey.shade300
                              : AppColors.primaryColor1.withOpacity(0.25),
                        ),
                      ),
                      child: Text(
                        target,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isUnknownTarget ? Colors.grey.shade700 : AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _MiniPill(
                      icon: Icons.repeat,
                      text: "$sets hiệp",
                    ),
                    const SizedBox(width: 8),
                    _MiniPill(
                      icon: Icons.fitness_center,
                      text: "$reps reps",
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      timeText,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryG),
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.history, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            "Chưa có lịch sử tập luyện",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            "Hãy hoàn thành một bài tập để hệ thống ghi nhận nhé.",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              backgroundColor: AppColors.primaryColor1.withOpacity(0.15),
              foregroundColor: AppColors.blackColor,
            ),
            onPressed: onRefresh,
            child: const Text(
              "Tải lại",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}
