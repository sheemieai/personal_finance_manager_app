import 'package:flutter/material.dart';

class InvestmentPage extends StatelessWidget {
  const InvestmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromARGB(255, 219, 189, 255),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Investment Display
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
               color: const Color.fromARGB(255, 219, 189, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Total Invest\n\$10,000',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),

            // Portfolio with Scrollable List
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 174, 142, 214),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  children: const [
                    InvestmentItem(company: 'Apple', amount: '\$5000'),
                    InvestmentItem(company: 'Adidas', amount: '\$5000'),
                    // Add more companies here
                  ],
                ),
              ),
            ),

            // Add and Back buttons
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Code for adding new investments
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                    ),
                    child: const Text('Add'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Code for going back to home page
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying companies to add
class InvestmentItem extends StatelessWidget {
  final String company;
  final String amount;

  const InvestmentItem({
    required this.company,
    required this.amount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            company,
            style: const TextStyle(fontSize: 50, color: Colors.white),
          ),
          Text(
            amount,
            style: const TextStyle(fontSize: 50, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
