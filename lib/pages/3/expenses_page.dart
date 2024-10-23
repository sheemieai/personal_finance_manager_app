import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../db/database_utils.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  String selectedCategory = "Expenses";
  final List<String> dropdownCategories = ["Expenses"];
  bool showExpensesField = false;
  bool showSnackBar = true;
  String currentExpenseSelected = "Expense";
  String currentExpenseSelectedHintTitle = "Add Expense";
  List<Map<String, dynamic>> selectedExpenseList = [];

  @override
  void initState() {
    super.initState();
    getDropdownCategories();
  }

  void getDropdownCategories() async {
    final String? username = await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId = await DatabaseHelper.instance.getUserIdByUsername(username!);

    if (userId != null) {
      final List<String> userExpensesList = await DatabaseHelper.instance
          .getUserExpenseNamesByUserId(userId);

      setState(() {
        dropdownCategories.removeRange(1, dropdownCategories.length);
        dropdownCategories.addAll(userExpensesList);
      });
    }
  }

  void addExpenseToDatabase() async {
    final String? username = await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId = await DatabaseHelper.instance.getUserIdByUsername(username!);

    if (userId != null) {
      if (selectedCategory == "Expenses") {
        if (expenseController.text.isNotEmpty) {
          final int? databaseAddExpenseResult = await DatabaseHelper.instance.createUserExpense(
              userId, expenseController.text.toLowerCase());

          getDropdownCategories();
          expenseController.clear();
        }
      } else {
        if (expenseController.text.isNotEmpty
            && costController.text.isNotEmpty && int.tryParse(costController.text) != null) {
          final int? selectedExpenseId = await DatabaseHelper.instance.getExpenseIdByNameAndUserId(
              selectedCategory.toLowerCase(), userId);

          if (selectedExpenseId != null) {
            final int? databaseAddSelectedExpenseResult = await DatabaseHelper.instance.createExpense(
                selectedExpenseId, expenseController.text.toLowerCase(), int.parse(costController.text));

            getSelectedExpenseData();

            expenseController.clear();
            costController.clear();
          }
        }
      }
    }
  }

  void getSelectedExpenseData() async {
    final String? username = await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId = await DatabaseHelper.instance.getUserIdByUsername(username!);

    if (userId != null) {
      final int? expenseId = await DatabaseHelper.instance.getExpenseIdByNameAndUserId(
          selectedCategory.toLowerCase(), userId);

      if (expenseId != null) {
        final List<Map<String, dynamic>> databaseSelectedExpenseList =
        await DatabaseHelper.instance.getAllExpensesByUserExpenseId(expenseId);

        setState(() {
          selectedExpenseList = databaseSelectedExpenseList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 300.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                          if (selectedCategory != "Expenses") {
                            currentExpenseSelectedHintTitle = "Add $selectedCategory Expense";
                            showExpensesField = true;
                          } else {
                            currentExpenseSelectedHintTitle = "Add Expense";
                            showExpensesField = false;
                          }
                          getSelectedExpenseData();
                        });
                      },
                      isExpanded: true,
                      items: dropdownCategories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (showExpensesField) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currentExpenseSelected,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 420.0,
                    child: Container(
                      width: 375.0,
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
                      child: Scrollbar(
                        thumbVisibility: true,
                        thickness: 6.0,
                        radius: const Radius.circular(10),
                        child: ListView.builder(
                          itemCount: selectedExpenseList.length,
                          itemBuilder: (context, index) {
                            final expense = selectedExpenseList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    expense["expense_name"],
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    "\$${expense["expense_cost"].toString()}  ",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
                if (showSnackBar) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: expenseController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: currentExpenseSelectedHintTitle,
                                  border: const OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: addExpenseToDatabase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[300],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (selectedCategory != "Expenses")
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 330.0,
                              child: TextField(
                                controller: costController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: "Cost",
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}