import 'package:flutter/material.dart';
import 'package:personal_finance_manager/db/database_utils.dart';

class InvestmentPage extends StatefulWidget {
  const InvestmentPage({super.key});

  @override
  _InvestmentPageState createState() => _InvestmentPageState();
}

class _InvestmentPageState extends State<InvestmentPage> {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  Map<String, String> investments = {};
  int totalInvestment = 0;

  @override
  void initState() {
    super.initState();
    _getInvestmentTotal();
    _getPortfolioMap();
  }

  @override
  void dispose() {
    companyController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _getInvestmentTotal() async {
    final String? username =
        await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId =
        await DatabaseHelper.instance.getUserIdByUsername(username!);
    final int databaseTotalInvestment =
        await DatabaseHelper.instance.getUserInvestmentTotalByUserId(userId!);
    setState(() {
      totalInvestment = databaseTotalInvestment;
    });
  }

  void _getPortfolioMap() async {
    final String? username =
        await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId =
        await DatabaseHelper.instance.getUserIdByUsername(username!);
    final Map<String, String> databaseInvestmentsMap =
        await DatabaseHelper.instance.getPortfoliosById(userId!);
    setState(() {
      investments = databaseInvestmentsMap;
    });
  }

  // Add Investment method
  void _addInvestment() async {
    String company = companyController.text.toLowerCase();
    String amount = amountController.text;
    final String? username =
        await DatabaseHelper.instance.getLoggedInUsername();
    final int? userId =
        await DatabaseHelper.instance.getUserIdByUsername(username!);
    final int? createInvestmentResult = await DatabaseHelper.instance
        .createInvestmentPortfolio(userId!, company, int.parse(amount));
    if (createInvestmentResult! > 0) {
      await DatabaseHelper.instance.updateTotalPortfolioAmountByUserId(userId);
      final int databaseTotalInvestment =
          await DatabaseHelper.instance.getUserInvestmentTotalByUserId(userId!);

      if (company.isNotEmpty && amount.isNotEmpty) {
        final Map<String, String> databaseInvestmentsMap =
            await DatabaseHelper.instance.getPortfoliosById(userId);
        setState(() {
          investments = databaseInvestmentsMap;
          totalInvestment = databaseTotalInvestment;
        });
        companyController.clear();
        amountController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromARGB(255, 219, 189, 255),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Investment Display
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 219, 189, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Total Invest\n\$${totalInvestment.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),

            // Portfolio with Scrollable List
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 174, 142, 214),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 6.0,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    itemCount: investments.length,
                    itemBuilder: (context, index) {
                      String key = investments.keys.elementAt(index);
                      return InvestmentItem(
                        company: key,
                        amount: investments[key]!,
                      );
                    },
                  ),
                ),
              ),
            ),

            // TextFields and Add button
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  // Text Field for company name
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: companyController,
                      decoration: const InputDecoration(
                        hintText: 'Company Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Text Field for amount
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Amount',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Add button
                  ElevatedButton(
                    onPressed: _addInvestment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
