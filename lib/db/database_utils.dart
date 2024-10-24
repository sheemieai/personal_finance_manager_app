import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("app.db");
    return _database!;
  }

  Future<Database> _initDB(final String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(final Database db, final int version) async {
    // Table for username and password
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL
    )
    ''');

    // Table for user income, connected to user table
    await db.execute('''
    CREATE TABLE user_income (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      income INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');

    // Table for user expenses, connected to user table
    await db.execute('''
    CREATE TABLE user_expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      user_expense_name TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');

    // Table for detailed expenses, connected to user_expenses table
    await db.execute('''
    CREATE TABLE expenses_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_expense_id INTEGER NOT NULL,
      expense_name TEXT NOT NULL,
      expense_cost INTEGER NOT NULL,
      FOREIGN KEY (user_expense_id) REFERENCES user_expenses (id) ON DELETE CASCADE
    )
    ''');

    // Table for user investment, connected to user table
    await db.execute('''
    CREATE TABLE user_investment (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      total_invest_amount INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');

    // Table for investment portfolio, connected to users table
    await db.execute('''
    CREATE TABLE investment_portfolio (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      portfolio_name TEXT NOT NULL,
      total_portfolio_amount INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');

    // Table for user savings, connected to user table
    // entry_month example: "october"
    // entry_date_number example: 13
    // entry_year example: "2024"
    // entry_day_of_week example: "sunday"
    // entry_name example: "grocery"
    // entry_cost example: 100
    await db.execute('''
    CREATE TABLE user_savings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      entry_month TEXT NOT NULL,
      entry_date_number INTEGER NOT NULL,
      entry_year TEXT NOT NULL,
      entry_day_of_week TEXT NOT NULL,
      entry_name TEXT NOT NULL,
      entry_cost INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');

    // Table for user budget, connected to user table
    await db.execute('''
    CREATE TABLE user_budget (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      daily_budget INTEGER NOT NULL,
      weekly_budget INTEGER NOT NULL,
      monthly_budget INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');

    // Current user logged in table
    await db.execute('''
    CREATE TABLE current_user (
      user_id INTEGER NOT NULL UNIQUE,
      username TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
    )
    ''');
  }

  // Users Table Functions
  Future<int> createUser(final String username, final String password) async {
    final db = await instance.database;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    return await db
        .insert("users", {"username": username, "password": hashedPassword});
  }

  Future<int?> validateUser(
      final String username, final String password) async {
    final db = await instance.database;

    // Query to find the user
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (users.isEmpty) {
      // No username found
      return null;
    } else {
      // Correct username and password
      final String hashedPassword =
          sha256.convert(utf8.encode(password)).toString();
      if (users.first['password'] == hashedPassword) {
        return users.first['id'];
      } else {
        // Wrong password
        return -1;
      }
    }
  }

  Future<bool> isUsernameTaken(final String username) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return users.isNotEmpty;
  }

  Future<int?> getUserIdByUsername(final String username) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "users",
      columns: ["id"],
      where: "username = ?",
      whereArgs: [username],
    );

    if (result.isEmpty) {
      return null;
    } else {
      return result.first["id"];
    }
  }

  // User Income Table Functions
  Future<int> createUserIncome(final int userId, final int income) async {
    final db = await instance.database;
    return await db.insert("user_income", {
      "user_id": userId,
      "income": income,
    });
  }

  Future<int> updateUserIncome(
      final int id, final int userId, final int income) async {
    final db = await instance.database;
    return await db.update(
      "user_income",
      {"user_id": userId, "income": income},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteUserIncome(final int id) async {
    final db = await instance.database;
    return await db.delete("user_income", where: "id = ?", whereArgs: [id]);
  }

  Future<bool> doesIncomeExist(final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "user_income",
      where: "user_id = ?",
      whereArgs: [userId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<int?> getIncomeIdByUserId(final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "user_income",
      columns: ["id"],
      where: "user_id = ?",
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first["id"];
    } else {
      return null;
    }
  }

  Future<int?> getIncomeByUserId(final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "user_income",
      columns: ["income"],
      where: "user_id = ?",
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first["income"] as int?;
    } else {
      return null;
    }
  }

  // User Expenses Table Functions
  Future<int?> createUserExpense(
      final int userId, final String userExpenseName) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> existingExpenses = await db.query(
      "user_expenses",
      where: "user_id = ? AND user_expense_name = ?",
      whereArgs: [userId, userExpenseName],
    );

    if (existingExpenses.isNotEmpty) {
      return null;
    }

    return await db.insert("user_expenses", {
      "user_id": userId,
      "user_expense_name": userExpenseName,
    });
  }

  Future<int> updateUserExpense(
      final int id, final int userId, final String userExpenseName) async {
    final db = await instance.database;
    return await db.update(
      "user_expenses",
      {"user_id": userId, "user_expense_name": userExpenseName},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteUserExpense(final int id) async {
    final db = await instance.database;
    return await db.delete("user_expenses", where: "id = ?", whereArgs: [id]);
  }

  Future<List<String>> getUserExpenseNamesByUserId(final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "user_expenses",
      columns: ["user_expense_name"],
      where: "user_id = ?",
      whereArgs: [userId],
    );

    List<String> expenseNames = result.map((row) {
      String expenseName = row["user_expense_name"] as String;
      return expenseName[0].toUpperCase() + expenseName.substring(1);
    }).toList();

    return expenseNames;
  }

  Future<int?> getExpenseIdByNameAndUserId(
      final String expenseName, final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "user_expenses",
      columns: ["id"],
      where: "user_expense_name = ? AND user_id = ?",
      whereArgs: [expenseName, userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first["id"] as int;
    } else {
      return null;
    }
  }

  // Expenses Table Functions
  Future<int> createExpense(final int userExpenseId, final String expenseName,
      final int expenseCost) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "expenses_table",
      where: "user_expense_id = ? AND expense_name = ?",
      whereArgs: [userExpenseId, expenseName],
    );

    if (result.isNotEmpty) {
      return await db.update(
        "expenses_table",
        {"expense_cost": expenseCost},
        where: "user_expense_id = ? AND expense_name = ?",
        whereArgs: [userExpenseId, expenseName],
      );
    } else {
      return await db.insert("expenses_table", {
        "user_expense_id": userExpenseId,
        "expense_name": expenseName,
        "expense_cost": expenseCost,
      });
    }
  }

  Future<int> updateExpense(final int id, final int userExpenseId,
      final String expenseName, final int expenseCost) async {
    final db = await instance.database;
    return await db.update(
      "expenses_table",
      {
        "user_expense_id": userExpenseId,
        "expense_name": expenseName,
        "expense_cost": expenseCost,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteExpense(final int id) async {
    final db = await instance.database;
    return await db.delete("expenses_table", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllExpensesByUserExpenseId(
      final int userExpenseId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "expenses_table",
      where: "user_expense_id = ?",
      whereArgs: [userExpenseId],
    );

    return result;
  }

  Future<int?> getExpenseIdByUserExpenseName(
      final String expenseName, final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "user_expenses",
      columns: ["id"],
      where: "user_expense_name = ? AND user_id = ?",
      whereArgs: [expenseName, userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first["id"] as int?;
    } else {
      return null;
    }
  }

  // User Investment Table Functions
  Future<int> createUserInvestment(
      final int userId, final int totalInvestAmount) async {
    final db = await instance.database;
    return await db.insert("user_investment", {
      "user_id": userId,
      "total_invest_amount": totalInvestAmount,
    });
  }

  Future<int> updateUserInvestment(
      final int id, final int userId, final int totalInvestAmount) async {
    final db = await instance.database;
    return await db.update(
      "user_investment",
      {"user_id": userId, "total_invest_amount": totalInvestAmount},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteUserInvestment(final int id) async {
    final db = await instance.database;
    return await db.delete("user_investment", where: "id = ?", whereArgs: [id]);
  }

  Future<int> getUserInvestmentTotalByUserId(final int userId) async {
    final db = await database;
    final result = await db.query(
      'user_investment',
      columns: ['total_invest_amount'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['total_invest_amount'] as int : 0;
  }

  // Investment Portfolio Table Functions
  Future<int> createInvestmentPortfolio(final int userId,
      final String portfolioName, final int totalPortfolioAmount) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "investment_portfolio",
      columns: ["id", "total_portfolio_amount"],
      where: "user_id = ? AND portfolio_name = ?",
      whereArgs: [userId, portfolioName],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final int portfolioId = result.first["id"] as int;
      final int existingAmount = result.first["total_portfolio_amount"] as int;
      final int updatedAmount = existingAmount + totalPortfolioAmount;

      return await db.update(
        "investment_portfolio",
        {"total_portfolio_amount": updatedAmount},
        where: "id = ?",
        whereArgs: [portfolioId],
      );
    } else {
      return await db.insert("investment_portfolio", {
        "user_id": userId,
        "portfolio_name": portfolioName,
        "total_portfolio_amount": totalPortfolioAmount,
      });
    }
  }

  Future<int> updateInvestmentPortfolio(final int id, final int userId,
      final String portfolioName, final int totalPortfolioAmount) async {
    final db = await instance.database;
    return await db.update(
      "investment_portfolio",
      {
        "user_id": userId,
        "portfolio_name": portfolioName,
        "total_portfolio_amount": totalPortfolioAmount,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> updatePortfolioAmount(
      final int portfolioId, final int newAmount) async {
    final db = await instance.database;

    await db.update(
      'investment_portfolio',
      {'total_portfolio_amount': newAmount},
      where: 'id = ?',
      whereArgs: [portfolioId],
    );
  }

  Future<int> deleteInvestmentPortfolio(int id) async {
    final db = await instance.database;
    return await db
        .delete("investment_portfolio", where: "id = ?", whereArgs: [id]);
  }

  Future<int?> getPortfolioIdByCompanyName(
      final int userId, final String portfolioName) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      'investment_portfolio',
      columns: ['id'],
      where: 'user_id = ? AND portfolio_name = ?',
      whereArgs: [userId, portfolioName],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return null;
    }
  }

  Future<void> updateTotalPortfolioAmountByUserId(final int userId) async {
    final db = await database;

    final portfolioResult = await db.query(
      'investment_portfolio',
      columns: ['total_portfolio_amount'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    int total = 0;
    for (var row in portfolioResult) {
      total += row['total_portfolio_amount'] as int;
    }

    final userInvestmentResult = await db.query(
      'user_investment',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (userInvestmentResult.isNotEmpty) {
      await db.update(
        'user_investment',
        {'total_invest_amount': total},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } else {
      await db.insert('user_investment', {
        'user_id': userId,
        'total_invest_amount': total,
      });
    }
  }

  Future<Map<String, String>> getPortfoliosById(final int userId) async {
    final db = await database;

    final portfolioResult = await db.query(
      'investment_portfolio',
      columns: ['portfolio_name', 'total_portfolio_amount'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    Map<String, String> portfolioMap = {};

    for (var row in portfolioResult) {
      portfolioMap[row['portfolio_name'] as String] =
          row['total_portfolio_amount'].toString();
    }

    return portfolioMap;
  }

  // User Savings Table Functions
  Future<int> createUserSavings(
      final int userId,
      final String entryMonth,
      final int entryDateNumber,
      final String entryYear,
      final String entryDayOfWeek,
      final String entryName,
      final int entryCost) async {
    final db = await instance.database;
    return await db.insert("user_savings", {
      "user_id": userId,
      "entry_month": entryMonth,
      "entry_date_number": entryDateNumber,
      "entry_year": entryYear,
      "entry_day_of_week": entryDayOfWeek,
      "entry_name": entryName,
      "entry_cost": entryCost,
    });
  }

  Future<int> updateUserSavings(
      final int id,
      final int userId,
      final String entryMonth,
      final int entryDateNumber,
      final String entryYear,
      final String entryDayOfWeek,
      final String entryName,
      final int entryCost) async {
    final db = await instance.database;
    return await db.update(
      "user_savings",
      {
        "user_id": userId,
        "entry_month": entryMonth,
        "entry_date_number": entryDateNumber,
        "entry_year": entryYear,
        "entry_day_of_week": entryDayOfWeek,
        "entry_name": entryName,
        "entry_cost": entryCost,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteUserSavings(final int id) async {
    final db = await instance.database;
    return await db.delete("user_savings", where: "id = ?", whereArgs: [id]);
  }

  // User Budget Table Functions
  Future<int> createUserBudget(final int userId, final int dailyBudget,
      final int weeklyBudget, final int monthlyBudget) async {
    final db = await instance.database;
    return await db.insert("user_budget", {
      "user_id": userId,
      "daily_budget": dailyBudget,
      "weekly_budget": weeklyBudget,
      "monthly_budget": monthlyBudget,
    });
  }

  Future<int> updateUserBudget(
      final int id,
      final int userId,
      final int dailyBudget,
      final int weeklyBudget,
      final int monthlyBudget) async {
    final db = await instance.database;
    return await db.update(
      "user_budget",
      {
        "user_id": userId,
        "daily_budget": dailyBudget,
        "weekly_budget": weeklyBudget,
        "monthly_budget": monthlyBudget,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<bool> setDailyBudget(final int userId, final int dailyBudget) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> existingBudget = await db.query(
      'user_budget',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (existingBudget.isEmpty) {
      await db.insert(
        'user_budget',
        {
          'user_id': userId,
          'daily_budget': dailyBudget,
          'weekly_budget': 0,
          'monthly_budget': 0,
        },
      );
    } else {
      await db.update(
        'user_budget',
        {
          'daily_budget': dailyBudget,
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    return true;
  }

  Future<int?> getDailyBudget(final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> budget = await db.query(
      'user_budget',
      columns: ['daily_budget'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (budget.isNotEmpty) {
      return budget.first['daily_budget'] as int?;
    }

    return null;
  }

  Future<bool> setWeeklyBudget(final int userId, final int weeklyBudget) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> existingBudget = await db.query(
      'user_budget',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (existingBudget.isEmpty) {
      await db.insert(
        'user_budget',
        {
          'user_id': userId,
          'daily_budget': 0,
          'weekly_budget': weeklyBudget,
          'monthly_budget': 0,
        },
      );
    } else {
      await db.update(
        'user_budget',
        {
          'weekly_budget': weeklyBudget,
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    return true;
  }

  Future<int?> getWeeklyBudget(final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> budget = await db.query(
      'user_budget',
      columns: ['weekly_budget'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (budget.isNotEmpty) {
      return budget.first['weekly_budget'] as int?;
    }

    return null;
  }

  Future<bool> setMonthlyBudget(
      final int userId, final int monthlyBudget) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> existingBudget = await db.query(
      'user_budget',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (existingBudget.isEmpty) {
      await db.insert(
        'user_budget',
        {
          'user_id': userId,
          'daily_budget': 0,
          'weekly_budget': 0,
          'monthly_budget': monthlyBudget,
        },
      );
    } else {
      await db.update(
        'user_budget',
        {
          'monthly_budget': monthlyBudget,
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    return true;
  }

  Future<int?> getMonthlyBudget(final int userId) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> budget = await db.query(
      'user_budget',
      columns: ['monthly_budget'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (budget.isNotEmpty) {
      return budget.first['monthly_budget'] as int?;
    }

    return null;
  }

  Future<int> deleteUserBudget(final int id) async {
    final db = await instance.database;
    return await db.delete("user_budget", where: "id = ?", whereArgs: [id]);
  }

  // Current User Table Functions
  Future<String?> getLoggedInUsername() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      "current_user",
      columns: ["username"],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    } else {
      return result.first["username"];
    }
  }

  Future<int> addLoggedInUser(final int userId, final String username) async {
    final db = await instance.database;

    await db.delete("current_user");

    return await db.insert(
      "current_user",
      {
        "user_id": userId,
        "username": username,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteLoggedInUser() async {
    final db = await instance.database;

    return await db.delete("current_user");
  }

  // Other database Functions
  Future<void> deleteDatabaseFile() async {
    // Deletes the database file
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    await deleteDatabase(path);
  }
}
