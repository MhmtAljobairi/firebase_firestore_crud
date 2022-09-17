import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_firebase_firestore_example/main.dart';
import 'package:get/utils.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;

  _handleRegisterAction() async {
    try {
      if (_formKey.currentState!.validate()) {
        UserCredential user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _controllerEmail.text,
                password: _controllerPassword.text);

        Get.to(MyHomePage());
      }
    } on FirebaseAuthException catch (ex) {
      if(ex.code=="email-already-in-use"){
      Get.defaultDialog(title: "Error Message", content: Text("The email address is alredy in use for another account"));

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register new account")),
      body: Container(
        child: Form(
          key: _formKey,
          child: Column(children: [
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
                    onPressed: _handleRegisterAction,
                    child: Text("Register!"))),
          ]),
        ),
      ),
    );
  }
}
