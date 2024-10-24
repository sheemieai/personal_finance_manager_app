import 'package:flutter/material.dart';
import 'package:personal_finance_manager/db/database_utils.dart';

class SavingGoalsPage extends StatefulWidget {
  const SavingGoalsPage({super.key});

  @override
  _SavingGoalsPageState createState() => _SavingGoalsPageState();
}

class _SavingGoalsPageState extends State<SavingGoalsPage> {
  String errorMessage = '';

  String selectedOption = '';
  int? currentSpending = 0;

  int? currentBudget = 0;

  final TextEditingController spendingController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentBudget();
    getCurrentSpending();
  }

  // Method to update (Daily, Weekly, Monthly)
  void updateOption(String option) {
    setState(() {
      selectedOption = option;
      errorMessage = '';
    });
  }

  // Method to get current spending
  void getCurrentSpending() async {
    final String? username =
        await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId =
        await DatabaseHelper.instance.getUserIdByUsername(username!);
    final int? databaseDailySpending =
        await DatabaseHelper.instance.getDailySavings(userId!);
    final int? databaseWeeklySpending =
        await DatabaseHelper.instance.getWeeklySavings(userId!);
    final int? databaseMonthlySpending =
        await DatabaseHelper.instance.getMonthlySavings(userId!);
    setState(() {
      switch (selectedOption) {
        case 'Daily':
          currentSpending = databaseDailySpending;
          break;
        case 'Weekly':
          currentSpending = databaseWeeklySpending;
          break;
        case 'Monthly':
          currentSpending = databaseMonthlySpending;
          break;
        default:
          currentSpending = databaseDailySpending;
          break;
      }
    });
  }

  // Method to get current budget
  void getCurrentBudget() async {
    final String? username =
        await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId =
        await DatabaseHelper.instance.getUserIdByUsername(username!);
    final int? databaseDailyBudget =
        await DatabaseHelper.instance.getDailyBudget(userId!);
    final int? databaseWeeklyBudget =
        await DatabaseHelper.instance.getWeeklyBudget(userId!);
    final int? databaseMonthlyBudget =
        await DatabaseHelper.instance.getMonthlyBudget(userId!);
    setState(() {
      switch (selectedOption) {
        case 'Daily':
          currentBudget = databaseDailyBudget;
          break;
        case 'Weekly':
          currentBudget = databaseWeeklyBudget;
          break;
        case 'Monthly':
          currentBudget = databaseMonthlyBudget;
          break;
        default:
          currentBudget = databaseDailyBudget;
          break;
      }
    });
  }

  // Method to validate the selection
  bool validateSelection() {
    if (selectedOption.isEmpty) {
      setState(() {
        errorMessage = 'Please select an option (Daily, Weekly, Monthly)!!';
      });
      return false;
    }
    setState(() {
      errorMessage = '';
    });
    return true;
  }

  // Method to add spending based on selection
  void addSpending() async {
    if (!validateSelection()) return;

    int enteredSpending = int.tryParse(spendingController.text) ?? 0;
    final String? username =
        await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId =
        await DatabaseHelper.instance.getUserIdByUsername(username!);

    switch (selectedOption) {
      case 'Daily':
        await DatabaseHelper.instance.setDailySavings(userId!, enteredSpending);
        break;
      case 'Weekly':
        await DatabaseHelper.instance
            .setWeeklySavings(userId!, enteredSpending);
        break;
      case 'Monthly':
        await DatabaseHelper.instance
            .setMonthlySavings(userId!, enteredSpending);
        break;
      default:
        break;
    }
    getCurrentSpending();
    spendingController.clear();
  }

  // Method to add budget based on selection
  void addBudget() async {
    if (!validateSelection()) return;

    int enteredBudget = int.tryParse(budgetController.text) ?? 0;
    final String? username =
        await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId =
        await DatabaseHelper.instance.getUserIdByUsername(username!);

    switch (selectedOption) {
      case 'Daily':
        await DatabaseHelper.instance.setDailyBudget(userId!, enteredBudget);
        break;
      case 'Weekly':
        await DatabaseHelper.instance.setWeeklyBudget(userId!, enteredBudget);
        break;
      case 'Monthly':
        await DatabaseHelper.instance.setMonthlyBudget(userId!, enteredBudget);
        break;
      default:
        break;
    }
    getCurrentBudget();
    budgetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Saving Goals',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Buttons for selecting Daily, Weekly, or Monthly
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Daily button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => {
                      updateOption('Daily'),
                      getCurrentBudget(),
                      getCurrentSpending()
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: selectedOption == 'Daily'
                          ? Colors.blue
                          : Colors.lightBlue[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Daily'),
                  ),
                ),
                const SizedBox(width: 10),
                // Weekly button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => {
                      updateOption('Weekly'),
                      getCurrentBudget(),
                      getCurrentSpending()
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: selectedOption == 'Weekly'
                          ? Colors.blue
                          : Colors.lightBlue[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Weekly'),
                  ),
                ),
                const SizedBox(width: 10),
                // Monthly button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => {
                      updateOption('Monthly'),
                      getCurrentBudget(),
                      getCurrentSpending()
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: selectedOption == 'Monthly'
                          ? Colors.blue
                          : Colors.lightBlue[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Monthly'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),

            const SizedBox(height: 20),
            // Display spending based on selection
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending for $selectedOption:',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${(currentSpending ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Display if the user is overspending
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Budget Information:',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${(currentBudget ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    (currentSpending ?? 0) > (currentBudget ?? 0)
                        ? 'You are overspending!'
                        : 'You are within your budget',
                    style: TextStyle(
                      fontSize: 18,
                      color: (currentSpending ?? 0) > (currentBudget ?? 0)
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Text Field for Changing Budget
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter Budget amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Change Budget Button
                ElevatedButton(
                  onPressed: () {
                    addBudget();
                  },
                  child: const Text('Change Budget'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // text field for adding spending
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: spendingController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter spending amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Add Spending Button
                ElevatedButton(
                  onPressed: () {
                    addSpending();
                  },
                  child: const Text('Add Spending'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
