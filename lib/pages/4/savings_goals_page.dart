import 'package:flutter/material.dart';
import '../../db/database_utils.dart';

class SavingGoalsPage extends StatefulWidget {
  const SavingGoalsPage({super.key});

  @override
  _SavingGoalsPageState createState() => _SavingGoalsPageState();
}

class _SavingGoalsPageState extends State<SavingGoalsPage> {
  // TODO change default values.
  String selectedOption = 'Daily';
  double dailySpending = 200.0;
  double weeklySpending = 800.0;
  double monthlySpending = 3000.0;
  double budget = 1000.0;

  // Method to update (Daily, Weekly, Monthly)
  void updateOption(String option) {
    setState(() {
      selectedOption = option;
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
                  child: const Text('Monthly'),
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
                ),
              ],
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
                    getCurrentSpending() > budget
                        ? 'You are overspending!'
                        : 'You are within your budget',
                    style: TextStyle(
                      fontSize: 18,
                      color: getCurrentSpending() > budget
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Change Budget Button
            ElevatedButton(
              onPressed: () {
                // TODO add logic to change budget
              },
              child: const Text('Change Budget'),
            ),
            const SizedBox(height: 10),
            // Add Spending Button
            ElevatedButton(
              onPressed: () {
                // TODO add logic for add button
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
