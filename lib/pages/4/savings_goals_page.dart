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
  final TextEditingController budgetController = TextEditingController();

  // Method to update (Daily, Weekly, Monthly)
  void updateOption(String option) {
    setState(() {
      selectedOption = option;
      errorMessage = '';
    });
  }

  // Method to get current spending
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

  // MEthod to get current budget
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
  void addSpending() {
    if (!validateSelection()) return;

    double enteredSpending = double.tryParse(spendingController.text) ?? 0.0;

    setState(() {
      switch (selectedOption) {
        case 'Daily':
          dailySpending += enteredSpending;
          break;
        case 'Weekly':
          weeklySpending += enteredSpending;
          break;
        case 'Monthly':
          monthlySpending += enteredSpending;
          break;
        default:
          break;
      }
      spendingController.clear();
    });
  }

  // Method to add budget based on selection
  void addBudget() {
    if (!validateSelection()) return;

    double enteredBudget = double.tryParse(budgetController.text) ?? 0.0;

    setState(() {
      switch (selectedOption) {
        case 'Daily':
          dailyBudget = enteredBudget;
          break;
        case 'Weekly':
          weeklyBudget = enteredBudget;
          break;
        case 'Monthly':
          monthlyBudget = enteredBudget;
          break;
        default:
          break;
      }
      budgetController.clear();
    });
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
                    onPressed: () => updateOption('Daily'),
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
                    onPressed: () => updateOption('Weekly'),
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
                    onPressed: () => updateOption('Monthly'),
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
