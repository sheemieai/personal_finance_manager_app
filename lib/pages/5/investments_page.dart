import 'package:flutter/material.dart';

class InvestmentPage extends StatelessWidget {
  const InvestmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple,
      child: const Center(
        child: Text(
          "Page 5",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}