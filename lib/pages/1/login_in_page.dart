import 'package:flutter/material.dart';

import '../../db/database_utils.dart';
import '../2/home_page.dart';

class LoginInPage extends StatefulWidget {
  LoginInPage({super.key});

  @override
  _LoginInPageState createState() => _LoginInPageState();
}

class _LoginInPageState extends State<LoginInPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController createUsernameController = TextEditingController();
  final TextEditingController createPasswordController = TextEditingController();
  String secondaryButtonTextString = "Sign Up";
  String alertTextFieldString = "";
  bool showCreateAccountFields = false;

  // Automatically makes the alert display disappear away a set time of seconds.
  void alertDisappearEffect() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        alertTextFieldString = "";
      });
    });
  }

  // Verifies the username and password entered in the text fields via the database
  void loginInButtonClicked() async {
    final int? databaseResult = await DatabaseHelper.instance.validateUser(
      usernameController.text.toLowerCase(), passwordController.text,
    );

    if (databaseResult == null) {
      setState(() {
        alertTextFieldString = "Incorrect username or password!";
      });
    } else if (databaseResult == -1) {
      setState(() {
        alertTextFieldString = "Wrong password!!";
      });
    } else {
      final int? userIdResult = await DatabaseHelper.instance.getUserIdByUsername(
          usernameController.text.toLowerCase());

      if (userIdResult != null && userIdResult > 0) {
        await DatabaseHelper.instance.addLoggedInUser(userIdResult,
            usernameController.text.toLowerCase());

        setState(() {
          alertTextFieldString = "Login successful!";
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        setState(() {
          alertTextFieldString = "Error: No user id";
        });
      }
    }

    alertDisappearEffect();
  }

  // Checks if the password has 1 uppercase, 1 lowercase, 1 symbol, and at least
  // 8+ characters
  bool validatePassword(final String password) {
    RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#\$&*~]).{8,}$',
    );

    return passwordRegExp.hasMatch(password);
  }

  // Shows the text fields that allows the user to create a new user
  void signUpButtonClicked() async {
    if (secondaryButtonTextString == "Sign Up") {
      setState(() {
        secondaryButtonTextString = "Create Account";
        showCreateAccountFields = true;
      });
    } else {
      final bool databaseUsernameResult = await DatabaseHelper.instance.isUsernameTaken(
          createUsernameController.text.toLowerCase());

      if (databaseUsernameResult) {
        setState(() {
          alertTextFieldString = "Username is already taken";
        });

        alertDisappearEffect();
        return;
      }

      if (!validatePassword(createPasswordController.text)) {
        setState(() {
          alertTextFieldString = "Password must have 1 uppercase letter, "
              "1 lowercase letter, 1 symbol, and be 8+ characters long";
        });

        alertDisappearEffect();
        return;
      }

      setState(() {
        secondaryButtonTextString = "Sign Up";
        showCreateAccountFields = false;
      });

      final int databaseResult = await DatabaseHelper.instance.createUser(
        createUsernameController.text.toLowerCase(), createPasswordController.text,
      );

      setState(() {
        if (databaseResult > 0) {
          alertTextFieldString = "User created";
        } else {
          alertTextFieldString = "User was not created";
        }
      });

      alertDisappearEffect();
    }
  }

  // Deletes the database file for testing if database changes are made
  Future<void> deleteDatabaseFile() async {
    await DatabaseHelper.instance.deleteDatabaseFile();
    setState(() {
      alertTextFieldString = "Database deleted and will be recreated.";
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        /*
        // Button used to delete the database if database changes are made
        appBar: AppBar(
          title: const Text("Reset Database"),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await deleteDatabaseFile();
              },
              tooltip: "Reset Database",
            ),
          ],
        ),
         */
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20.0),
                // Container that holds the app name, log in fields, and create
                // user fields.
                Container(
                  width: 200.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Image.asset(
                      "lib/pages/1/img/logoFinanceApp.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: 400.0,
                  height: 45.0,
                  child: Text(
                    alertTextFieldString,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Login in fields
                const SizedBox(height: 15.0),
                SizedBox(
                  width: 400.0,
                  height: 45.0,
                  child: TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Username",
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                SizedBox(
                  width: 400.0,
                  height: 45.0,
                  child: TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Password",
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 15.0),
                SizedBox(
                  width: 400.0,
                  child: ElevatedButton(
                    onPressed: () {
                      loginInButtonClicked();
                      passwordController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white),
                    child: const Text("Login"),
                  ),
                ),
                const SizedBox(height: 5.0),
                // Sign up fields
                SizedBox(
                  width: 400.0,
                  child: ElevatedButton(
                    onPressed: () {
                      signUpButtonClicked();
                      usernameController.clear();
                      passwordController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white),
                    child: Text(secondaryButtonTextString),
                  ),
                ),
                if (showCreateAccountFields) ...[
                  const SizedBox(height: 25.0),
                  SizedBox(
                    width: 400.0,
                    height: 45.0,
                    child: TextField(
                      controller: createUsernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Create Username",
                      ),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  SizedBox(
                    width: 400.0,
                    height: 45.0,
                    child: TextField(
                      controller: createPasswordController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Create User Password",
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Container(
                    width: 300.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Text(
                        "Password must have \n\t\t1 uppercase letter, "
                            "\n\t\t1 lowercase letter, "
                            "\n\t\t1 symbol, "
                            "and \n\t\tbe 8+ characters long",
                        style: TextStyle(color: Colors.white),
                      ),
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
