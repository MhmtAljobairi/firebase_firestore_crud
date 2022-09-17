import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_firebase_firestore_example/main.dart';
import 'package:flutter_application_firebase_firestore_example/register_page.dart';
import 'package:get/utils.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;

  _handleLoginAction() async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _controllerEmail.text,
                password: _controllerPassword.text);
        // print(user);

        Get.to(MyHomePage());
      }
    } on FirebaseAuthException catch (ex) {
      print(ex);
      if (ex.code == "user-not-found") {
        Get.defaultDialog(
            title: "Error Message",
            content: const Text("Email or Password is not found"));
      } else if (ex.code == "wrong-password") {
        Get.defaultDialog(
            title: "Error Message",
            content: const Text(
                "The password is invalid or the user does not have a password."));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            Image.network(
                "https://cdn.dribbble.com/users/528264/screenshots/3140440/firebase_logo.png"),
            const Text(
              "Welcome to our App",
              style: TextStyle(
                fontSize: 35,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "To access the books app, you must login",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _controllerEmail,
              keyboardType: TextInputType.emailAddress,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return "Please check your email address";
                }

                if (!GetUtils.isEmail(text)) {
                  return "Please add a valid email address";
                }
              },
              decoration: const InputDecoration(
                  hintText: "john@example.com", prefixIcon: Icon(Icons.email)),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _controllerPassword,
              keyboardType: TextInputType.visiblePassword,
              obscureText: obscureText,
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return "Please check your password";
                }
                if (text.length < 5) {
                  return "Password must be greater than 5 char";
                }
              },
              decoration: InputDecoration(
                  hintText: "Password",
                  suffix: GestureDetector(
                    child: const Icon(Icons.remove_red_eye),
                    onTap: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  ),
                  prefixIcon: const Icon(Icons.password)),
            ),
            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _handleLoginAction, child: Text("Login!"))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: const Text("Forget Password"),
                  onTap: () {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: _controllerEmail.text);
                  },
                ),
                InkWell(
                  child: const Text("Create an account"),
                  onTap: () {
                 Get.to(RegisterPage());
                  },
                )
              ],
            )
          ]),
        ),
      ),
    );
  }
}
