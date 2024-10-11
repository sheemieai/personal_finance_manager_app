import 'package:flutter/material.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: const Center(
        child: Text(
          "Page 3",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}