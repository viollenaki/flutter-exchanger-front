import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  const CustomLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            spreadRadius: 12,
            blurRadius: 100,
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet,
        size: 80,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
