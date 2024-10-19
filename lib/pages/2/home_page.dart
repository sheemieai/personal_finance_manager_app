import 'package:flutter/material.dart';

import '../../db/database_utils.dart';
import '../1/login_in_page.dart';
import '../3/expenses_page.dart';
import '../4/savings_goals_page.dart';
import '../5/investments_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController incomeController = TextEditingController();
  String incomeTextString = "";
  bool showIncomeChangeField = false;
  String changeIncomeTextString = "Change Income";
  String alertTextFieldString = "";
  String usernameTextString = "";

  @override
  void initState() {
    super.initState();
    setIncomeInformation();
    getLoggedInUsername();
  }

  void getLoggedInUsername() async {
    final String? databaseUsername = await DatabaseHelper.instance.getLoggedInUsername();

    setState(() {
      if (databaseUsername != null && databaseUsername.isNotEmpty) {
        usernameTextString = databaseUsername[0].toUpperCase() +
            databaseUsername.substring(1).toLowerCase();
      }
    });
  }

  void alertDisappearEffect() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        alertTextFieldString = "";
      });
    });
  }

  void setIncomeInformation() async {
    final String? username = await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId = await DatabaseHelper.instance.getUserIdByUsername(username!);

    if (userId != null) {
      final bool incomeExists = await DatabaseHelper.instance.doesIncomeExist(userId);

      if (incomeExists) {
        final int? userIncome = await DatabaseHelper.instance.getIncomeByUserId(userId);
        setState(() {
          incomeTextString = userIncome?.toString() ?? "No Income Set";
        });
      } else {
        changeIncomeButton();
      }
    } else {
      setState(() {
        incomeTextString = "User not found";
      });

      signOutButton();
    }
  }

  void expensesButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpensesPage()),
    );
  }

  void savingGoalsButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavingGoalsPage()),
    );
  }

  void investmentButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InvestmentPage()),
    );
  }

  void signOutButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginInPage()),
    );
  }

  Future<void> changeIncomeButton() async {
    if (changeIncomeTextString == "Change Income") {
      setState(() {
        changeIncomeTextString = "Submit";
        showIncomeChangeField = true;
      });
    } else {
      final String? databaseUsernameResult =
      await DatabaseHelper.instance.getLoggedInUsername();
      final int? userId = await DatabaseHelper.instance.getUserIdByUsername(
          databaseUsernameResult!);

      if (userId != null) {
        final bool incomeExists = await DatabaseHelper.instance.doesIncomeExist(userId);

        int? incomeValue;
        try {
          incomeValue = int.parse(incomeController.text);
        } catch (e) {
          setState(() {
            alertTextFieldString = "Please enter a valid income amount. All numbers";
          });

          alertDisappearEffect();
          return;
        }

        if (incomeExists) {
          final int? incomeId = await DatabaseHelper.instance.getIncomeIdByUserId(userId);
          if (incomeId != null) {
            await DatabaseHelper.instance.updateUserIncome(incomeId, userId, incomeValue);
          }
        } else {
          await DatabaseHelper.instance.createUserIncome(userId, incomeValue);
        }

        final int? userIncome = await DatabaseHelper.instance.getIncomeByUserId(userId);

        setState(() {
          incomeTextString = userIncome?.toString() ?? "No Income Set";
          changeIncomeTextString = "Change Income";
          incomeController.clear();
          alertTextFieldString = "Income Changed.";
          showIncomeChangeField = false;
        });
      } else {
        setState(() {
          alertTextFieldString = "User not found.";
        });
      }
    }

    alertDisappearEffect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Home",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40.0),
              Container(
                width: 400.0,
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(bottom: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "$usernameTextString's Income:",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 15.0),
                    Text(
                      incomeTextString,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 15.0),
                    if (showIncomeChangeField) ...[
                      SizedBox(
                        height: 45.0,
                        child: TextField(
                          controller: incomeController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "New Income",
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 15.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          changeIncomeButton();
                        },
                        child: Text(changeIncomeTextString),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              Text(
                  alertTextFieldString
              ),
              const SizedBox(height: 25.0),
              SizedBox(
                width: 400.0,
                child: ElevatedButton(
                  onPressed: expensesButton,
                  child: const Text("Expenses"),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 400.0,
                child: ElevatedButton(
                  onPressed: savingGoalsButton,
                  child: const Text("Savings Goals"),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 400.0,
                child: ElevatedButton(
                  onPressed: investmentButton,
                  child: const Text("Investments"),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                width: 400.0,
                child: ElevatedButton(
                  onPressed: signOutButton,
                  child: const Text("Sign Out"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
