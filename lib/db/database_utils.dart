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
  }

  // Users Table Functions
  Future<int> createUser(final String username, final String password) async {
    final db = await instance.database;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    return await db.insert(
        "users", {"username": username, "password": hashedPassword});
  }

  Future<int?> validateUser(final String username, final String password) async {
    final db = await instance.database;
    final hashedPassword = sha256.convert(utf8.encode(password)).toString();

    final result = await db.query(
        "users", where: "username = ? AND password = ?",
        whereArgs: [username, hashedPassword]);

    if (result.isNotEmpty) {
      return result.first["id"] as int?;
    } else {
      return null;
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

  Future<int> updateUserIncome(final int id, final int userId, final int income) async {
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

  // User Expenses Table Functions
  Future<int> createUserExpense(final int userId, final String userExpenseName) async {
    final db = await instance.database;
    return await db.insert("user_expenses", {
      "user_id": userId,
      "user_expense_name": userExpenseName,
    });
  }

  Future<int> updateUserExpense(final int id, final int userId, final String userExpenseName) async {
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

  // Expenses Table Functions
  Future<int> createExpense(final int userExpenseId, final String expenseName,
      final int expenseCost) async {
    final db = await instance.database;
    return await db.insert("expenses_table", {
      "user_expense_id": userExpenseId,
      "expense_name": expenseName,
      "expense_cost": expenseCost,
    });
  }

  Future<int> updateExpense(final int id, final int userExpenseId, final String expenseName,
      final int expenseCost) async {
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

  // User Investment Table Functions
  Future<int> createUserInvestment(final int userId, final int totalInvestAmount) async {
    final db = await instance.database;
    return await db.insert("user_investment", {
      "user_id": userId,
      "total_invest_amount": totalInvestAmount,
    });
  }

  Future<int> updateUserInvestment(final int id, final int userId, final int totalInvestAmount) async {
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

  // Investment Portfolio Table Functions
  Future<int> createInvestmentPortfolio(final int userId, final String portfolioName,
      int totalPortfolioAmount) async {
    final db = await instance.database;
    return await db.insert("investment_portfolio", {
      "user_id": userId,
      "portfolio_name": portfolioName,
      "total_portfolio_amount": totalPortfolioAmount,
    });
  }

  Future<int> updateInvestmentPortfolio(final int id, final int userId, final String portfolioName,
      final int totalPortfolioAmount) async {
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

  Future<int> deleteInvestmentPortfolio(int id) async {
    final db = await instance.database;
    return await db.delete("investment_portfolio", where: "id = ?", whereArgs: [id]);
  }

  // User Savings Table Functions
  Future<int> createUserSavings(final int userId, final String entryMonth, final int entryDateNumber,
      final String entryYear, final String entryDayOfWeek, final String entryName,
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

  Future<int> updateUserSavings(final int id, final int userId, final String entryMonth,
      final int entryDateNumber, final String entryYear, final String entryDayOfWeek,
      final String entryName, final int entryCost) async {
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
  Future<int> createUserBudget(final int userId, final int dailyBudget, final int weeklyBudget,
      final int monthlyBudget) async {
    final db = await instance.database;
    return await db.insert("user_budget", {
      "user_id": userId,
      "daily_budget": dailyBudget,
      "weekly_budget": weeklyBudget,
      "monthly_budget": monthlyBudget,
    });
  }

  Future<int> updateUserBudget(final int id, final int userId, final int dailyBudget,
      final int weeklyBudget, final int monthlyBudget) async {
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

  Future<int> deleteUserBudget(final int id) async {
    final db = await instance.database;
    return await db.delete("user_budget", where: "id = ?", whereArgs: [id]);
  }
}