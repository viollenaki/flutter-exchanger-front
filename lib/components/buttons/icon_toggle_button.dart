import 'package:flutter/material.dart';

class IconToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color? selectedColor;

  const IconToggleButton({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = selectedColor ?? Theme.of(context).primaryColor;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? effectiveColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? effectiveColor : Colors.grey,
          width: 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: effectiveColor.withOpacity(0.4),  // Increased opacity from 0.3 to 0.4
            blurRadius: 12,                          // Increased from 8 to 12
            spreadRadius: 2,                         // Increased from 1 to 2
            offset: const Offset(0, 2),
          ),
        ] : [],
      ),
      transform: isSelected 
          ? Matrix4.translationValues(0, -4, 0)  // Changed from -2 to -4
          : Matrix4.translationValues(0, 0, 0),
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
        ),
        onPressed: onPressed,
      ),
    );
  }
}