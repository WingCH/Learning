import 'package:flutter/material.dart';

enum CommonButtonStyle { normal, outline }

class CommonButton extends StatelessWidget {
  final CommonButtonStyle buttonStyle;
  final VoidCallback onPressed;
  final String? title;
  final Widget? titleWidget;
  final bool isBtnEnabled;
  final Color? bgColor;
  final Color? disabledBgColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final EdgeInsets? customPadding;
  final TextStyle? textStyle;
  final int? maxLines;
  final TextOverflow overFlow;

  const CommonButton({
    super.key,
    this.buttonStyle = CommonButtonStyle.normal,
    this.title,
    this.titleWidget,
    this.isBtnEnabled = true,
    this.bgColor,
    this.disabledBgColor,
    this.textColor,
    this.disabledTextColor,
    this.customPadding,
    this.maxLines = 1,
    this.overFlow = TextOverflow.ellipsis,
    required this.onPressed,
    this.textStyle,
  }) : assert(title != null || titleWidget != null,
            'title or titleWidget must be provided');

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding = customPadding ??
        const EdgeInsets.symmetric(vertical: 12, horizontal: 20);

    final isNormalBtnStyle = buttonStyle == CommonButtonStyle.normal;

    final Color primaryColor = isBtnEnabled
        ? bgColor ?? Color(0xFF6C8489)
        : disabledBgColor ?? Color(0xFFE6E6E6);

    final Color btnBgColor =
        isNormalBtnStyle ? primaryColor : Colors.transparent;

    final Color primaryTextColor = isBtnEnabled
        ? textColor ?? Color(0xFFFFFFFF)
        : disabledTextColor ?? Color(0xFF000000);

    final Color btnTextColor =
        isNormalBtnStyle ? primaryTextColor : primaryColor;

    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        foregroundColor: Color(0xFF000000),
        backgroundColor: btnBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: isNormalBtnStyle
              ? BorderSide.none
              : BorderSide(
                  width: 2,
                  color: primaryColor,
                ),
        ),
        padding: padding,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: isBtnEnabled ? onPressed : null,
      child: titleWidget ??
          Text(
            title ?? '',
            textAlign: TextAlign.center,
            maxLines: maxLines,
            overflow: overFlow,
            style: textStyle ?? TextStyle(color: btnTextColor),
          ),
    );
  }
}
