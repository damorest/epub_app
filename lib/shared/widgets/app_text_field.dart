import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.helperText,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final Widget? helperText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.label,
          ),
          const SizedBox(height: 9),
        ],
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.body.copyWith(color: AppColors.text3),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppColors.text3, size: 20)
                  : null,
              filled: true,
              fillColor: _focused
                  ? AppColors.inputFocusedBg
                  : AppColors.surface,
              border: _border(),
              enabledBorder: _border(),
              focusedBorder: _border(color: AppColors.goldLine),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 8),
          DefaultTextStyle(
            style: AppTypography.hint,
            child: widget.helperText!,
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border({Color color = AppColors.line}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.5),
      );
}
