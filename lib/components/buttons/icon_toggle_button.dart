
import 'package:flutter/material.dart';

class IconToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;

  const IconToggleButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blueAccent : Colors.white,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: isSelected ? Colors.blueAccent : Colors.white,
        onPressed: onPressed,
      ),
    );
  }
}