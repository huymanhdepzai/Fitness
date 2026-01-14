import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../common_widgets/round_button.dart';
import '../../services/notification_service.dart';
import '../../user/services/user_local_storage.dart';
import '../../utils/app_colors.dart';
import '../../workouts/db/exercise_db_repository.dart';
import '../../workouts/db/isar_db.dart';
import 'workout_note_storage.dart';

class DailyScheduleView extends StatefulWidget {
  const DailyScheduleView({Key? key}) : super(key: key);

  @override
  State<DailyScheduleView> createState() => _DailyScheduleViewState();
}

class _DailyScheduleViewState extends State<DailyScheduleView> {
  final _exerciseRepo = ExerciseDbRepository(IsarDb());

  String? _userGoal;
  List<TargetGroup> _groups = [];
  bool _loadingGroups = true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<WorkoutNote> _allNotes = [];
  List<WorkoutNote> _selectedDayNotes = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _normalize(DateTime.now());
    _loadNotes();
    _loadGoalAndGroups();
  }

  Future<void> _loadGoalAndGroups() async {
    final user = await UserLocalStorage.getUser();
    final goal = user?.goal;

    if (!mounted) return;
    setState(() {
      _userGoal = goal;
      _loadingGroups = true;
    });

    if (goal == null || goal.isEmpty) {
      setState(() {
        _groups = [];
        _loadingGroups = false;
      });
      return;
    }

    await _exerciseRepo.init();
    final groups = await _exerciseRepo.getTargetGroupsForGoal(goal);

    if (!mounted) return;
    setState(() {
      _groups = groups;
      _loadingGroups = false;
    });
  }

  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _loadNotes() async {
    final notes = await WorkoutNoteStorage.loadNotes();
    if (!mounted) return;
    setState(() {
      _allNotes = notes;
      _selectedDayNotes = _selectedDay == null ? [] : _getNotesForDay(_selectedDay!);
      _loading = false;
    });
  }

  List<WorkoutNote> _getNotesForDay(DateTime day) {
    final normalized = _normalize(day);
    return _allNotes.where((n) => _normalize(n.dateTime) == normalized).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  String _fmtDateVN(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtTimeVN(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _weekdayVN(DateTime d) {
    const map = {
      DateTime.monday: 'Thứ 2',
      DateTime.tuesday: 'Thứ 3',
      DateTime.wednesday: 'Thứ 4',
      DateTime.thursday: 'Thứ 5',
      DateTime.friday: 'Thứ 6',
      DateTime.saturday: 'Thứ 7',
      DateTime.sunday: 'Chủ nhật',
    };
    return map[d.weekday] ?? '';
  }

  Future<void> _addNote() async {
    if (_selectedDay == null) return;

    final titleController = TextEditingController();
    final descController = TextEditingController();

    TimeOfDay selectedTime = TimeOfDay.now();

    TargetGroup? selectedGroup;
    String? selectedExerciseName;

    bool loadingExercises = false;
    List<String> exerciseNames = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> loadExercisesForGroup(TargetGroup g) async {
              final goal = _userGoal;
              if (goal == null || goal.isEmpty) return;

              setModalState(() {
                loadingExercises = true;
                exerciseNames = [];
                selectedExerciseName = null;
              });

              final names = await _exerciseRepo.getExerciseNamesForGoalAndTarget(
                goal: goal,
                target: g.target,
              );

              setModalState(() {
                exerciseNames = names;
                loadingExercises = false;
              });
            }

            Widget sectionTitle(String t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                t,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blackColor,
                ),
              ),
            );

            InputDecoration inputDeco({
              required String label,
              String? hint,
              Widget? prefixIcon,
            }) {
              return InputDecoration(
                labelText: label,
                hintText: hint,
                prefixIcon: prefixIcon,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Header bottom sheet
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.primaryG),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.edit_calendar, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thêm lịch tập',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              _selectedDay == null
                                  ? ''
                                  : '${_weekdayVN(_selectedDay!)} • ${_fmtDateVN(_selectedDay!)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grayColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Nhóm bài tập
                  sectionTitle('Nhóm bài tập'),
                  DropdownButtonFormField<TargetGroup>(
                    value: selectedGroup,
                    decoration: inputDeco(
                      label: 'Chọn nhóm',
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: _groups
                        .map(
                          (g) => DropdownMenuItem(
                        value: g,
                        child: Text('${g.target} (${g.count})'),
                      ),
                    )
                        .toList(),
                    onChanged: (_loadingGroups || _groups.isEmpty)
                        ? null
                        : (g) async {
                      if (g == null) return;
                      setModalState(() => selectedGroup = g);
                      await loadExercisesForGroup(g);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Bài tập
                  sectionTitle('Bài tập'),
                  if (_loadingGroups)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_userGoal == null || _userGoal!.isEmpty)
                    const Text(
                      'Bạn chưa chọn mục tiêu nên chưa có danh sách bài tập.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  else if (selectedGroup == null)
                      const Text(
                        'Chọn nhóm bài tập để hiển thị danh sách bài.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    else if (loadingExercises)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        DropdownButtonFormField<String>(
                          isExpanded: true, // ✅ QUAN TRỌNG: cho dropdown chiếm hết chiều ngang
                          value: selectedExerciseName,
                          decoration: inputDeco(
                            label: 'Chọn bài tập',
                            prefixIcon: const Icon(Icons.fitness_center_outlined),
                          ),
                          items: exerciseNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // ✅ tránh tràn
                              ),
                            );
                          }).toList(),
                          onChanged: (name) {
                            setModalState(() => selectedExerciseName = name);
                            if (name != null && titleController.text.trim().isEmpty) {
                              titleController.text = name;
                            }
                          },
                          selectedItemBuilder: (context) {
                            // ✅ cách hiển thị khi đã chọn cũng ellipsis
                            return exerciseNames.map((name) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList();
                          },
                        ),
                  const SizedBox(height: 12),

                  // Tiêu đề
                  sectionTitle('Tiêu đề'),
                  TextField(
                    controller: titleController,
                    decoration: inputDeco(
                      label: 'Tiêu đề lịch tập',
                      hint: 'Ví dụ: Tập tay sau / Cardio nhẹ',
                      prefixIcon: const Icon(Icons.title_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ghi chú
                  sectionTitle('Ghi chú'),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: inputDeco(
                      label: 'Ghi chú chi tiết',
                      hint: 'Ví dụ: 3 hiệp, nghỉ 60s...',
                      prefixIcon: const Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Time picker dạng chip
                  sectionTitle('Giờ tập'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ChipButton(
                        icon: Icons.access_time,
                        label:
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                      ),
                      if (selectedExerciseName != null && selectedExerciseName!.trim().isNotEmpty)
                        _ChipButton(
                          icon: Icons.check_circle_outline,
                          label: 'Đã chọn bài',
                          onTap: () {},
                          enabled: false,
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: RoundButton(
                      title: 'Lưu & đặt thông báo',
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;

                        final day = _selectedDay!;
                        final dateTime = DateTime(
                          day.year,
                          day.month,
                          day.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        final idStr = DateTime.now().millisecondsSinceEpoch.toString();
                        final notificationId = idStr.hashCode;

                        final descText = descController.text.trim();
                        final mergedDesc = selectedExerciseName == null
                            ? (descText.isEmpty ? null : descText)
                            : ([
                          'Bài tập: $selectedExerciseName',
                          if (descText.isNotEmpty) descText,
                        ].join('\n'));

                        final note = WorkoutNote(
                          id: idStr,
                          notificationId: notificationId,
                          dateTime: dateTime,
                          title: titleController.text.trim(),
                          description: mergedDesc,
                        );

                        await WorkoutNoteStorage.addNote(note);
                        await _loadNotes();

                        await NotificationService.scheduleWorkoutNotification(
                          id: notificationId,
                          dateTime: dateTime,
                          title: note.title,
                          body: note.description ?? 'Đến giờ tập luyện rồi! 💪',
                        );

                        if (context.mounted) Navigator.pop(context);
                      },
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

  Future<void> _deleteNote(WorkoutNote note) async {
    await WorkoutNoteStorage.deleteNote(note);
    await NotificationService.cancelNotification(note.notificationId);
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final selected = _selectedDay;

    final headerText = selected == null
        ? 'Lịch tập'
        : '${_weekdayVN(selected)} • ${_fmtDateVN(selected)}';

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
            'Lịch tập luyện hằng ngày',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addNote,
          backgroundColor: AppColors.primaryColor2,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Tạo ghi chú',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 6),

            // Calendar card đẹp hơn
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: TableCalendar<WorkoutNote>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                selectedDayPredicate: (day) =>
                _selectedDay != null && _normalize(day) == _normalize(_selectedDay!),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = _normalize(selectedDay);
                    _focusedDay = focusedDay;
                    _selectedDayNotes = _getNotesForDay(_selectedDay!);
                  });
                },
                eventLoader: _getNotesForDay,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  weekendStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: const TextStyle(color: Colors.white),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: AppColors.secondaryColor1.withOpacity(0.35),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.55), width: 1),
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: AppColors.primaryColor1,
                    fontWeight: FontWeight.w900,
                  ),
                  markerSize: 6,
                  markersAlignment: Alignment.bottomCenter,
                  markerDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Danh sách note (card + header + empty state đẹp hơn)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                decoration: const BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header list + count
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            headerText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor1.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_selectedDayNotes.length} ghi chú',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: _selectedDayNotes.isEmpty
                          ? _EmptyState(onAdd: _addNote)
                          : ListView.separated(
                        padding: const EdgeInsets.only(top: 2, bottom: 90),
                        itemCount: _selectedDayNotes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final note = _selectedDayNotes[index];
                          final timeStr = _fmtTimeVN(note.dateTime);

                          return Dismissible(
                            key: ValueKey(note.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _deleteNote(note),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: AppColors.primaryG),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.fitness_center,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              note.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.blackColor,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryColor1
                                                        .withOpacity(0.10),
                                                    borderRadius:
                                                    BorderRadius.circular(999),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons.access_time,
                                                          size: 14,
                                                          color: AppColors.grayColor),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        timeStr,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w800,
                                                          color: AppColors.grayColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                if (note.description != null &&
                                                    note.description!
                                                        .trim()
                                                        .isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange
                                                          .withOpacity(0.10),
                                                      borderRadius:
                                                      BorderRadius.circular(999),
                                                    ),
                                                    child: const Text(
                                                      'Nhắc nhở',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w800,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (note.description != null &&
                                      note.description!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      note.description!.trim(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.3,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// Widgets nhỏ cho UI đẹp hơn
// =========================

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.blackColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: enabled ? AppColors.blackColor : AppColors.grayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryColor1.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.event_note, size: 30, color: AppColors.blackColor),
            ),
            const SizedBox(height: 10),
            const Text(
              'Chưa có ghi chú nào',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hãy tạo lịch tập để nhắc bạn đúng giờ 💪',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.grayColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // SizedBox(
            //   height: 40,
            //   child: ElevatedButton.icon(
            //     onPressed: onAdd,
            //     icon: const Icon(Icons.add),
            //     label: const Text('Tạo ghi chú'),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor2,
            //       foregroundColor: Colors.white,
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            //       elevation: 0,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
