import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum OptionVisualState {
  neutral,
  correct,
  wrong,
  disabled,
}

class OptionButton extends StatelessWidget {
  final String labelPrefix;
  final String text;
  final OptionVisualState visualState;
  final VoidCallback? onTap;

  const OptionButton({
    super.key,
    required this.labelPrefix,
    required this.text,
    required this.visualState,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    Color borderColor = theme.colorScheme.outline;
    Color textColor = theme.colorScheme.onSurface;
    IconData? trailingIcon;

    switch (visualState) {
      case OptionVisualState.correct:
        bgColor = isDark
            ? AppColors.successContainerDark
            : AppColors.successContainerLight;
        borderColor = isDark ? AppColors.successDark : AppColors.successLight;
        textColor = isDark ? AppColors.successDark : AppColors.successLight;
        trailingIcon = Icons.check_circle_rounded;
      case OptionVisualState.wrong:
        bgColor = isDark
            ? AppColors.errorContainerDark
            : AppColors.errorContainerLight;
        borderColor = isDark ? AppColors.errorDark : AppColors.errorLight;
        textColor = isDark ? AppColors.errorDark : AppColors.errorLight;
        trailingIcon = Icons.cancel_rounded;
      case OptionVisualState.disabled:
        textColor = theme.colorScheme.onSurface.withValues(alpha: 0.45);
      case OptionVisualState.neutral:
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: visualState == OptionVisualState.neutral ||
                        visualState == OptionVisualState.disabled
                    ? 1
                    : 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    labelPrefix,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, color: textColor, size: 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
