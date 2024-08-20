import 'package:flutter/material.dart';

class MyElevatedButton extends StatefulWidget {
  final void Function()? onTap;

  Widget? child;
  Color color;

  MyElevatedButton({super.key, required this.onTap, required this.child, required this.color});

  @override
  State<MyElevatedButton> createState() => _MyElevatedButtonState();
}

class _MyElevatedButtonState extends State<MyElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onTap,
      child: widget.child,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(widget.color) ,
      ),
    );
  }
}
