import 'package:flutter/material.dart';

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({
    Key? key,
    required this.backgroundColor,
    required this.borderColor,
    required this.initialValue,
  }) : super(key: key);

  final Color backgroundColor;
  final Color borderColor;
  final bool initialValue;

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  late bool isSwitched;

  @override
  void initState() {
    isSwitched = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSwitched = !isSwitched;
        });
      },
      child: Container(
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(
            color: widget.borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          alignment: isSwitched ? Alignment.centerLeft : Alignment.centerRight,
          duration: const Duration(seconds: 1),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.borderColor,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
