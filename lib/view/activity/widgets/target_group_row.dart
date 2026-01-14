import 'package:flutter/material.dart';
import 'package:fitnessapp/utils/app_colors.dart';

class TargetGroupRow extends StatelessWidget {
  final String title;
  final int count;
  final String? previewGifUrl;
  final VoidCallback? onTap;

  const TargetGroupRow({
    super.key,
    required this.title,
    required this.count,
    this.previewGifUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.primaryColor2.withOpacity(0.18),
              AppColors.primaryColor1.withOpacity(0.18)
            ]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 54,
                  height: 54,
                  color: AppColors.lightGrayColor,
                  child: previewGifUrl == null || previewGifUrl!.isEmpty
                      ? const Icon(Icons.fitness_center, color: AppColors.grayColor)
                      : Image.network(
                    previewGifUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fitness_center,
                      color: AppColors.grayColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count bài tập',
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grayColor),
            ],
          ),
        ),
      ),
    );
  }
}
