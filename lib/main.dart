import 'package:flutter/material.dart';
import 'pages/1/login_in_page.dart';
import 'pages/2/home_page.dart';
import 'pages/3/expenses_page.dart';
import 'pages/4/savings_goals_page.dart';
import 'pages/5/investments_page.dart';

void main() {
  runApp(ColorPagesApp());
}

class ColorPagesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Color Pages App",
      home: ColorPages(),
    );
  }
}

class ColorPages extends StatelessWidget {
  // List of pages
  final List<Widget> pages = [
    LoginInPage(),
    HomePage(),
    ExpensesPage(),
    SavingGoalsPage(),
    InvestmentPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Color Pages"),
      ),
      body: PageView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          return pages[index]; // Change index here to switch pages
        },
      ),
    );
  }
}