import 'dart:io';

import 'package:fitnessapp/common_widgets/round_button.dart';
import 'package:fitnessapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/notification_service.dart';
import '../daily_schedule_view/workout_note_storage.dart';
import 'progress_photo_storage.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _picker = ImagePicker();

  bool _loading = true;
  List<ProgressPhotoItem> _all = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _fmtVN(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String _fmtVNShort(DateTime d) {
    // dd/MM
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await ProgressPhotoStorage.load();
    if (!mounted) return;
    setState(() {
      _all = items;
      _loading = false;
    });
  }

  DateTime? _nextReminderDate() {
    if (_all.isEmpty) return null;
    // latest photo day + 7 days
    final latestDay = _dateOnly(_all.first.dateTime);
    return latestDay.add(const Duration(days: 7));
  }

  Future<void> _createNextReminderNoteIfNeeded() async {
    final next = _nextReminderDate();
    if (next == null) return;

    // đặt nhắc lúc 09:00 sáng ngày next
    final remindAt = DateTime(next.year, next.month, next.day, 9, 0);

    // tránh tạo trùng: nếu đã có note cùng ngày & title thì thôi
    final notes = await WorkoutNoteStorage.loadNotes();
    final exist = notes.any((n) =>
    _dateOnly(n.dateTime) == _dateOnly(remindAt) &&
        (n.title.trim().toLowerCase() == 'chụp ảnh tiến độ'));

    if (exist) return;

    final idStr = DateTime.now().millisecondsSinceEpoch.toString();
    final notificationId = idStr.hashCode;

    final note = WorkoutNote(
      id: idStr,
      notificationId: notificationId,
      dateTime: remindAt,
      title: 'Chụp ảnh tiến độ',
      description: 'Đến ngày chụp ảnh tiến độ tiếp theo 💪',
    );

    await WorkoutNoteStorage.addNote(note);

    await NotificationService.scheduleWorkoutNotification(
      id: notificationId,
      dateTime: remindAt,
      title: note.title,
      body: note.description ?? 'Đến giờ chụp ảnh tiến độ 💪',
    );
  }

  Future<void> _pickAndSave(ImageSource src) async {
    try {
      final x = await _picker.pickImage(
        source: src,
        imageQuality: 88,
      );
      if (x == null) return;

      final now = DateTime.now();
      final savedPath =
      await ProgressPhotoStorage.saveImageFileToLocal(File(x.path), now);

      await ProgressPhotoStorage.addPhoto(dateTime: now, filePath: savedPath);

      await _load();

      // sau khi thêm ảnh -> tạo nhắc nhở ảnh tiếp theo + ghi chú
      await _createNextReminderNoteIfNeeded();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu ảnh vào phòng trưng bày')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể thêm ảnh: $e')),
      );
    }
  }

  void _openAddPhotoSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Thêm ảnh tiến độ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndSave(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndSave(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openCompare() {
    final pair = ProgressPhotoStorage.findComparePair(_all);
    if (pair == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cần ít nhất 2 ảnh và ảnh cũ phải cách ảnh mới nhất tối thiểu 7 ngày.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'So sánh hình ảnh',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _CompareCard(
                      label: 'Ảnh cũ',
                      dateText: _fmtVN(pair.older.dateTime),
                      filePath: pair.older.filePath,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CompareCard(
                      label: 'Mới nhất',
                      dateText: _fmtVN(pair.newest.dateTime),
                      filePath: pair.newest.filePath,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor2,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deletePhoto(ProgressPhotoItem item) async {
    await ProgressPhotoStorage.deletePhoto(item);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    final next = _nextReminderDate();
    final nextText = next == null ? '--' : _fmtVN(next);

    final grouped =
    ProgressPhotoStorage.groupByDay(List<ProgressPhotoItem>.from(_all));
    final days = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // newest day first

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: const Text(
          "Ảnh tiến độ",
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {
              // menu nhỏ
              final act = await showModalBottomSheet<String>(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Tải lại'),
                        onTap: () => Navigator.pop(context, 'reload'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.add_a_photo_outlined),
                        title: const Text('Thêm ảnh'),
                        onTap: () => Navigator.pop(context, 'add'),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              );

              if (act == 'reload') {
                await _load();
              } else if (act == 'add') {
                _openAddPhotoSheet();
              }
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lightGrayColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                "assets/icons/more_icon.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: AppColors.whiteColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminder card
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFE5E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/icons/date_notifi.png",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nhắc nhở!",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Hình ảnh tiếp theo vào ngày $nextText",
                              style: const TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (next != null)
                              SizedBox(
                                height: 28,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await _createNextReminderNoteIfNeeded();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Đã tạo nhắc nhở'),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: BorderSide(
                                        color: Colors.red.withOpacity(0.35)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const Text(
                                    'Tạo nhắc nhở',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12),
                                  ),
                                ),
                              )
                            // else
                            //   const Text(
                            //     'Hãy thêm ảnh đầu tiên để bắt đầu lịch nhắc.',
                            //     style: TextStyle(
                            //       fontSize: 12,
                            //       color: AppColors.grayColor,
                            //       fontWeight: FontWeight.w600,
                            //     ),
                            //   )
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.close,
                          color: AppColors.grayColor,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: media.width * 0.05),

              // Compare
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                    vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor2.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "So sánh hình ảnh",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 25,
                      child: RoundButton(
                        title: "So sánh",
                        onPressed: _openCompare,
                      ),
                    )
                  ],
                ),
              ),

              // Gallery header
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Phòng trưng bày",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: _openAddPhotoSheet,
                      child: const Text(
                        "Thêm ảnh",
                        style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              if (_all.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 30),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined,
                            size: 46, color: Colors.grey.shade500),
                        const SizedBox(height: 10),
                        const Text(
                          "Chưa có ảnh nào",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Hãy thêm ảnh để theo dõi tiến độ mỗi tuần 💪",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grayColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // const SizedBox(height: 12),
                        // SizedBox(
                        //   height: 40,
                        //   child: ElevatedButton.icon(
                        //     onPressed: _openAddPhotoSheet,
                        //     icon: const Icon(Icons.add_a_photo_outlined),
                        //     label: const Text("Thêm ảnh"),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColors.primaryColor2,
                        //       foregroundColor: Colors.white,
                        //       elevation: 0,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(14),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final items = grouped[day] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(8, 12, 8, 8),
                          child: Text(
                            _fmtVN(day),
                            style: const TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 6),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final it = items[i];
                              return _PhotoCard(
                                filePath: it.filePath,
                                label: _fmtVNShort(it.dateTime),
                                onDelete: () => _deletePhoto(it),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

              SizedBox(height: media.width * 0.1),
            ],
          ),
        ),
      ),
      floatingActionButton: InkWell(
        onTap: _openAddPhotoSheet,
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.secondaryG),
            borderRadius: BorderRadius.circular(27.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              )
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.photo_camera,
            size: 20,
            color: AppColors.whiteColor,
          ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String filePath;
  final String label;
  final VoidCallback onDelete;

  const _PhotoCard({
    required this.filePath,
    required this.label,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.lightGrayColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(filePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: InkWell(
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xoá ảnh?'),
                  content: const Text('Ảnh sẽ bị xoá khỏi thiết bị.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Huỷ'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xoá'),
                    ),
                  ],
                ),
              );
              if (ok == true) onDelete();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.delete, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompareCard extends StatelessWidget {
  final String label;
  final String dateText;
  final String filePath;

  const _CompareCard({
    required this.label,
    required this.dateText,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(filePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          dateText,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grayColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
