import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemSound + HapticFeedback
import 'package:fitnessapp/utils/app_colors.dart';

import '../../workouts/db/exercise_db_repository.dart';
import '../../workouts/db/exercise_entity.dart';
import '../../workouts/db/isar_db.dart';

class ExerciseInstructionsView extends StatefulWidget {
  final String exerciseId;
  const ExerciseInstructionsView({super.key, required this.exerciseId});

  @override
  State<ExerciseInstructionsView> createState() =>
      _ExerciseInstructionsViewState();
}

class _ExerciseInstructionsViewState extends State<ExerciseInstructionsView> {
  final _repo = ExerciseDbRepository(IsarDb());

  ExerciseEntity? _e;
  bool _loading = true;

  // ===== Workout settings =====
  int _reps = 10;
  int _sets = 3;

  // ===== Timer settings (editable) =====
  int _workSeconds = 30;
  int _restSeconds = 30;

  // ===== Timer state =====
  Timer? _timer;
  bool _running = false;
  bool _paused = false;
  bool _isRest = false;
  int _currentSet = 1;
  int _remaining = 30;

  bool _handlingPhase = false; // chống double-trigger

  @override
  void initState() {
    super.initState();
    _remaining = _workSeconds;
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    await _repo.init();
    final e = await _repo.getByExerciseId(widget.exerciseId);
    if (!mounted) return;
    setState(() {
      _e = e;
      _loading = false;
    });
  }

  // ===== Helpers =====
  String _titleCase(String s) {
    final words = s.split(RegExp(r'\s+'));
    return words
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _fmtDateTime(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  // ===== Workout flow =====
  void _startWorkout() {
    if (_e == null) return;

    _timer?.cancel();
    setState(() {
      _running = true;
      _paused = false;
      _isRest = false;
      _currentSet = 1;
      _remaining = _workSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (!_running || _paused) return;

      if (_remaining > 1) {
        setState(() => _remaining -= 1);
        return;
      }
      _onPhaseFinished();
    });
  }

  void _stopWorkout({bool reset = true}) {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _running = false;
      _paused = false;
      if (reset) {
        _isRest = false;
        _currentSet = 1;
        _remaining = _workSeconds;
      }
    });
  }

  void _togglePause() {
    if (!_running) return;
    setState(() => _paused = !_paused);
    HapticFeedback.selectionClick();
  }

  void _skipPhase() {
    if (!_running) return;
    _onPhaseFinished(force: true);
  }

  Future<void> _phaseFeedback() async {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  Future<void> _onPhaseFinished({bool force = false}) async {
    if (_handlingPhase) return;
    _handlingPhase = true;

    try {
      if (!_running) return;

      if (!force) {
        await _phaseFeedback();
      } else {
        HapticFeedback.selectionClick();
      }

      if (!_isRest) {
        // finished WORK phase of current set
        if (_currentSet >= _sets) {
          _timer?.cancel();
          setState(() {
            _running = false;
            _paused = false;
          });

          await _saveWorkoutHistory();
          if (!mounted) return;

          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Hoàn thành! 💪'),
              content: Text(
                'Bạn đã hoàn thành $_sets hiệp • $_reps reps/hiệp\n'
                    'Bài: ${_e?.name ?? ''}\n'
                    'Thời gian: ${_fmtDateTime(DateTime.now())}',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ],
            ),
          );
          return;
        }

        // go to REST
        setState(() {
          _isRest = true;
          _remaining = _restSeconds;
        });
        return;
      } else {
        // finished REST -> next set WORK
        setState(() {
          _isRest = false;
          _currentSet += 1;
          _remaining = _workSeconds;
        });
      }
    } finally {
      _handlingPhase = false;
    }
  }

  Future<void> _saveWorkoutHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _e == null) return;

    final now = DateTime.now();
    final totalSeconds = _sets * _workSeconds + (_sets - 1) * _restSeconds;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workout_history')
        .add({
      'exerciseId': _e!.exerciseId,
      'exerciseName': _e!.name,
      'primaryTarget': _e!.primaryTarget,
      'reps': _reps,
      'sets': _sets,
      'workSeconds': _workSeconds,
      'restSeconds': _restSeconds,
      'totalSeconds': totalSeconds,
      'performedAt': Timestamp.fromDate(now),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ===== UI bits =====
  Widget _pillChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightGrayColor.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: Colors.grey.shade800),
        ),
      ),
    );
  }

  Widget _settingCard({
    required String title,
    required String subtitle,
    required int value,
    required int min,
    required int max,
    required VoidCallback onDec,
    required VoidCallback onInc,
    required IconData icon,
    String? trailingUnit,
  }) {
    final canDec = !_running && value > min;
    final canInc = !_running && value < max;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryG),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _circleIconButton(
                    icon: Icons.remove, enabled: canDec, onTap: onDec),
                const SizedBox(width: 10),
                Text(
                  trailingUnit == null ? '$value' : '$value$trailingUnit',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(width: 10),
                _circleIconButton(
                    icon: Icons.add, enabled: canInc, onTap: onInc),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _timerRing() {
    final phaseTotal = _isRest ? _restSeconds : _workSeconds;
    final progress =
    phaseTotal == 0 ? 0.0 : (1 - (_remaining / phaseTotal)).clamp(0.0, 1.0);
    final color = _isRest ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_remaining',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: color),
                    ),
                    Text(
                      _paused ? 'Pause' : (_isRest ? 'Rest' : 'Work'),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRest ? 'Nghỉ' : 'Tập',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: color),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hiệp: $_currentSet/$_sets • Reps: $_reps',
                  style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(_sets, (i) {
                    final done = i < (_currentSet - (_isRest ? 0 : 1));
                    final active = i == (_currentSet - 1);
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      width: active ? 18 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: done
                            ? Colors.green
                            : (active
                            ? color.withOpacity(0.55)
                            : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Icon(_isRest ? Icons.self_improvement : Icons.fitness_center,
              color: color),
        ],
      ),
    );
  }

  Widget _heroImage(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_running) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đang tập luyện"),
        content: const Text("Bạn muốn dừng buổi tập và thoát?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Ở lại")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Dừng & Thoát"),
          ),
        ],
      ),
    );
    if (ok == true) {
      _stopWorkout(reset: true);
      return true;
    }
    return false;
  }

  // ===== NEW: open bottom sheet settings =====
  Future<void> _openWorkoutSettingsSheet() async {
    if (_loading || _e == null) return;

    // snapshot current values
    int reps = _reps;
    int sets = _sets;
    int work = _workSeconds;
    int rest = _restSeconds;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            // same lock rule: đang chạy thì không cho chỉnh
            final locked = _running;

            Widget header() => Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: AppColors.primaryG),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Thiết lập buổi tập",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.blackColor),
                  ),
                ),
                if (locked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "Đang tập • khóa chỉnh",
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange),
                    ),
                  ),
              ],
            );

            Widget tinyHint(String text) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                text,
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            );

            // local setting cards (dùng lại _settingCard)
            Widget card({
              required String title,
              required String subtitle,
              required int value,
              required int min,
              required int max,
              required IconData icon,
              required VoidCallback onDec,
              required VoidCallback onInc,
              String? unit,
            }) {
              final canDec = !locked && value > min;
              final canInc = !locked && value < max;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.primaryG),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: canDec ? onDec : null,
                            borderRadius: BorderRadius.circular(999),
                            child: Opacity(
                              opacity: canDec ? 1 : 0.35,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.08)),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.remove,
                                    size: 18, color: Colors.grey.shade800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            unit == null ? '$value' : '$value$unit',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: canInc ? onInc : null,
                            borderRadius: BorderRadius.circular(999),
                            child: Opacity(
                              opacity: canInc ? 1 : 0.35,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.08)),
                                ),
                                alignment: Alignment.center,
                                child: Icon(Icons.add,
                                    size: 18, color: Colors.grey.shade800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // grabber
                  Container(
                    width: 46,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),

                  header(),
                  tinyHint(
                    locked
                        ? "Bạn chỉ có thể chỉnh khi đã dừng buổi tập."
                        : "Thiết lập sẽ áp dụng cho buổi tập kế tiếp.",
                  ),
                  const SizedBox(height: 14),

                  card(
                    title: "Reps mỗi hiệp",
                    subtitle: "Số lần lặp lại / hiệp",
                    value: reps,
                    min: 1,
                    max: 50,
                    icon: Icons.repeat,
                    onDec: () => setModal(() => reps -= 1),
                    onInc: () => setModal(() => reps += 1),
                  ),
                  const SizedBox(height: 10),
                  card(
                    title: "Số hiệp (Sets)",
                    subtitle: "Tổng số hiệp bạn muốn tập",
                    value: sets,
                    min: 1,
                    max: 12,
                    icon: Icons.layers,
                    onDec: () => setModal(() => sets -= 1),
                    onInc: () => setModal(() => sets += 1),
                  ),
                  const SizedBox(height: 10),
                  card(
                    title: "Work",
                    subtitle: "Thời gian tập mỗi hiệp",
                    value: work,
                    min: 10,
                    max: 180,
                    unit: "s",
                    icon: Icons.timer,
                    onDec: () => setModal(
                            () => work = (work - 5).clamp(10, 180)),
                    onInc: () => setModal(
                            () => work = (work + 5).clamp(10, 180)),
                  ),
                  const SizedBox(height: 10),
                  card(
                    title: "Rest",
                    subtitle: "Thời gian nghỉ giữa các hiệp",
                    value: rest,
                    min: 5,
                    max: 180,
                    unit: "s",
                    icon: Icons.self_improvement,
                    onDec: () =>
                        setModal(() => rest = (rest - 5).clamp(5, 180)),
                    onInc: () =>
                        setModal(() => rest = (rest + 5).clamp(5, 180)),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: locked
                          ? null
                          : () {
                        // apply
                        setState(() {
                          _reps = reps;
                          _sets = sets;
                          _workSeconds = work;
                          _restSeconds = rest;

                          // nếu chưa chạy -> cập nhật preview remaining
                          if (!_running) _remaining = _workSeconds;
                        });

                        Navigator.pop(ctx);
                        HapticFeedback.selectionClick();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primaryColor2,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        "Lưu thiết lập",
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = _e;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryG)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Hướng dẫn",
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            leading: InkWell(
              onTap: () async {
                if (await _onWillPop()) {
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.grey.shade800, size: 20),
              ),
            ),
          ),

          // ✅ NEW: Floating button mở thiết lập (ẩn khi đang loading/null)
          // floatingActionButton: (_loading || e == null)
          //     ? null
          //     : FloatingActionButton.extended(
          //   onPressed: _openWorkoutSettingsSheet,
          //   backgroundColor: AppColors.primaryColor2,
          //   icon: const Icon(Icons.tune, color: Colors.white),
          //   label: const Text(
          //     "Thiết lập",
          //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          //   ),
          // ),

          body: Container(
            decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : (e == null)
                        ? const Center(child: Text('Không tìm thấy bài tập.'))
                        : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.name,
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),

                          _heroImage(e.gifUrl),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (e.primaryTarget.isNotEmpty)
                                _pillChip(
                                    icon: Icons.adjust,
                                    text: 'Target: ${_titleCase(e.primaryTarget)}'),
                              if (e.bodyParts.isNotEmpty)
                                _pillChip(
                                    icon: Icons.accessibility_new,
                                    text: 'Part: ${_titleCase(e.bodyParts.first)}'),
                              if (e.equipments.isNotEmpty)
                                _pillChip(
                                    icon: Icons.handyman,
                                    text: 'Equip: ${_titleCase(e.equipments.first)}'),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ✅ THAY vì show "Thiết lập buổi tập" đầy đủ,
                          // ta chỉ show 1 card tóm tắt (preview)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: AppColors.primaryG),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.tune, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Thiết lập buổi tập",
                                        style: TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Reps: $_reps • Sets: $_sets • Work: ${_workSeconds}s • Rest: ${_restSeconds}s",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _openWorkoutSettingsSheet,
                                  child: const Text(
                                    "Sửa",
                                    style: TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _running ? _timerRing() : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 18),
                          const Text(
                            "Instructions",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),

                          if (e.instructions.isEmpty)
                            Text('Chưa có hướng dẫn.',
                                style: TextStyle(color: AppColors.grayColor))
                          else
                            Column(
                              children: List.generate(e.instructions.length, (i) {
                                final step = e.instructions[i].trim();
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrayColor.withOpacity(0.42),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: AppColors.primaryG),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: const TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 13,
                                            height: 1.35,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          // const SizedBox(height: 6),
                          // Text(
                          //   'Lưu lịch sử khi hoàn thành đủ hiệp.',
                          //   style: TextStyle(
                          //     color: Colors.grey.shade600,
                          //     fontSize: 11,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // ===== Bottom action bar =====
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(22),
                      ),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading || e == null
                                  ? null
                                  : (_running ? () => _stopWorkout(reset: true) : _startWorkout),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor:
                                _running ? Colors.red.shade400 : AppColors.primaryColor2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _running ? "Dừng" : "Bắt đầu",
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ),
                        if (_running) ...[
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 48,
                            width: 56,
                            child: ElevatedButton(
                              onPressed: _togglePause,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Icon(_paused ? Icons.play_arrow : Icons.pause, size: 22),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 48,
                            width: 56,
                            child: ElevatedButton(
                              onPressed: _skipPhase,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Icon(Icons.skip_next, size: 22),
                            ),
                          ),
                        ],
                      ],
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
}
