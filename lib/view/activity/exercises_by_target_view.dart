import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';

import '../../workouts/db/exercise_db_repository.dart';
import '../../workouts/db/exercise_entity.dart';
import '../../workouts/db/isar_db.dart';
import '../workour_detail_view/widgets/exercise_card_row.dart';
import 'exercise_instructions_view.dart';

/// ✅ Wrapper screen (có AppBar, gradient)
class ExercisesByTargetView extends StatelessWidget {
  final String goal;
  final String target; // lowercase

  const ExercisesByTargetView({
    super.key,
    required this.goal,
    required this.target,
  });

  String _beautify(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    final words = t.split(RegExp(r'\s+'));
    return words.map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final title = _beautify(target);

    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10),
              ),
              // child: Image.asset(
              //   "assets/icons/back_icon.png",
              //   width: 15,
              //   height: 15,
              //   fit: BoxFit.contain,
              // ),
              child: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.grey.shade800, size: 20),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: ExercisesByTargetBody(
            goal: goal,
            target: target,
            padding: EdgeInsets.zero,
            // default onTap sẽ mở instruction screen
          ),
        ),
      ),
    );
  }
}

/// ✅ Body list (KHÔNG Scaffold/AppBar) => dùng để nhúng vào WorkoutDetailView
class ExercisesByTargetBody extends StatefulWidget {
  final String goal;
  final String target;

  /// padding bên trong list (khi nhúng vào màn khác)
  final EdgeInsets padding;

  /// nếu muốn tự xử lý click item (ví dụ mở màn khác)
  final void Function(BuildContext context, ExerciseEntity e)? onItemTap;

  /// page size
  final int pageSize;

  const ExercisesByTargetBody({
    super.key,
    required this.goal,
    required this.target,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.onItemTap,
    this.pageSize = 20,
  });

  @override
  State<ExercisesByTargetBody> createState() => _ExercisesByTargetBodyState();
}

class _ExercisesByTargetBodyState extends State<ExercisesByTargetBody> {
  final _repo = ExerciseDbRepository(IsarDb());

  final List<ExerciseEntity> _items = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _loading = false;
    });

    await _repo.init();
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;

    setState(() => _loading = true);

    final next = await _repo.getByGoalAndTargetPaged(
      goal: widget.goal,
      target: widget.target,
      page: _page,
      pageSize: widget.pageSize,
    );

    if (!mounted) return;
    setState(() {
      _items.addAll(next);
      _page += 1;
      _hasMore = next.length == widget.pageSize;
      _loading = false;
    });
  }

  void _defaultTap(BuildContext context, ExerciseEntity e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseInstructionsView(exerciseId: e.exerciseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ListView.builder(
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          // footer
          if (index == _items.length) {
            if (_loading && _items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!_hasMore) return const SizedBox(height: 24);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _loading ? null : _loadMore,
                  child: _loading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Xem thêm'),
                ),
              ),
            );
          }

          final e = _items[index];
          return ExerciseCardRow(
            e: e,
            onTap: () {
              final handler = widget.onItemTap;
              if (handler != null) {
                handler(context, e);
              } else {
                _defaultTap(context, e);
              }
            },
          );
        },
      ),
    );
  }
}
