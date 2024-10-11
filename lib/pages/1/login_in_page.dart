import 'package:flutter/material.dart';

class LoginInPage extends StatelessWidget {
  const LoginInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: const Center(
        child: Text(
          "Page 1",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}