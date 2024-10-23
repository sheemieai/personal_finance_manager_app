import 'package:flutter/material.dart';
import '../../db/database_utils.dart';

class SavingGoalsPage extends StatefulWidget {
  const SavingGoalsPage({super.key});

  @override
  _SavingGoalsPageState createState() => _SavingGoalsPageState();
}

class _SavingGoalsPageState extends State<SavingGoalsPage> {
  String errorMessage = '';

  String selectedOption = '';
  double dailySpending = 0.0;
  double weeklySpending = 0.0;
  double monthlySpending = 0.0;

  double dailyBudget = 0.0;
  double weeklyBudget = 0.0;
  double monthlyBudget = 0.0;

  final TextEditingController spendingController = TextEditingController();
  final TextEditingController BudgetController = TextEditingController();

  // Method to update (Daily, Weekly, Monthly)
  void updateOption(String option) {
    setState(() {
      selectedOption = option;
      errorMessage = '';
    });
  }

  double getCurrentSpending() {
    switch (selectedOption) {
      case 'Daily':
        return dailySpending;
      case 'Weekly':
        return weeklySpending;
      case 'Monthly':
        return monthlySpending;
      default:
        return dailySpending;
    }
  }

  double getCurrentBudget() {
    switch (selectedOption) {
      case 'Daily':
        return dailyBudget;
      case 'Weekly':
        return weeklyBudget;
      case 'Monthly':
        return monthlyBudget;
      default:
        return dailyBudget;
    }
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
              // Button displays
              children: [
                // Daily button
                ElevatedButton(
                  onPressed: () => updateOption('Daily'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 40.0),
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
                // Weekly button
                ElevatedButton(
                  onPressed: () => updateOption('Weekly'),
                  child: const Text('Weekly'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 40.0),
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
                ),
                // Monthly button
                ElevatedButton(
                  onPressed: () => updateOption('Monthly'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 40.0),
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
                    '\$${getCurrentSpending().toStringAsFixed(2)}',
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
                    '\$${getCurrentBudget().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getCurrentSpending() > getCurrentBudget()
                        ? 'You are overspending!'
                        : 'You are within your budget',
                    style: TextStyle(
                      fontSize: 18,
                      color: getCurrentSpending() > getCurrentBudget()
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Text Field for Changing Budget
            TextField(
              controller: BudgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Budget amount',
                border: OutlineInputBorder(),
              ),
            ),
            // Change Budget Button
            ElevatedButton(
              onPressed: () {
                if (selectedOption.isEmpty) {
                  setState(() {
                    errorMessage =
                        'Please select an option (Daily, Weekly, Monthly)!!';
                  });
                  return;
                }
                double enteredBudget =
                    double.tryParse(BudgetController.text) ?? 0.0;
                setState(() {
                  if (selectedOption == 'Daily') {
                    dailyBudget = enteredBudget;
                  } else if (selectedOption == 'Weekly') {
                    weeklyBudget = enteredBudget;
                  } else if (selectedOption == 'Monthly') {
                    monthlyBudget = enteredBudget;
                  }
                  BudgetController.clear();
                });
              },
              child: const Text('Change Budget'),
            ),
            const SizedBox(height: 10),
            // text field for adding spending
            TextField(
              controller: spendingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter spending amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Add button
            ElevatedButton(
              onPressed: () {
                if (selectedOption.isEmpty) {
                  setState(() {
                    errorMessage =
                        'Please select an option (Daily, Weekly, Monthly)!!';
                  });
                  return;
                }
                double enteredSpending =
                    double.tryParse(spendingController.text) ?? 0.0;
                setState(() {
                  if (selectedOption == 'Daily') {
                    dailySpending += enteredSpending;
                  } else if (selectedOption == 'Weekly') {
                    weeklySpending += enteredSpending;
                  } else if (selectedOption == 'Monthly') {
                    monthlySpending += enteredSpending;
                  }
                  spendingController.clear();
                });
              },
              child: const Text('Add Spending'),
            ),
            const SizedBox(height: 10),
            // Back Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
