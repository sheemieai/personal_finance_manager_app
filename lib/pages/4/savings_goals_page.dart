import 'package:flutter/material.dart';

class SavingGoalsPage extends StatelessWidget {
  const SavingGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      child: const Center(
        child: Text(
          "Page 4",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}