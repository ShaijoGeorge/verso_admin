import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:verso_admin/core/design/design.dart';

class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    super.key,
    this.subtitle,
    this.trendText,
    this.isPositiveTrend = true,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final String? trendText;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colors;

    return VersoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.borderRadiusMD,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: accentColor,
                ),
              ),
              if (trendText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isPositiveTrend ? context.appColors.success : colors.error)
                        .withValues(alpha: 0.12),
                    borderRadius: AppRadii.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 13,
                        color: isPositiveTrend
                            ? context.appColors.success
                            : colors.error,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        trendText!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPositiveTrend
                              ? context.appColors.success
                              : colors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Gap(Spacing.md),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const Gap(4),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
