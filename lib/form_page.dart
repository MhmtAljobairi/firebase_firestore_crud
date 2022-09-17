import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormPage extends StatefulWidget {
  final dynamic docment;
  const FormPage({super.key, this.docment});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPublisher = TextEditingController();
  final TextEditingController _controllerYear = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.docment != null) {
      _controllerName.text = widget.docment['name'];
      _controllerPublisher.text = widget.docment['publisher'];
      _controllerYear.text = widget.docment['year'];
    }
  }

  erfre() async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: "", password: "");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }

    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  erferf() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  _handleSubmitAction() async {
    if (_formKey.currentState!.validate()) {
      if (widget.docment != null) {
        await FirebaseFirestore.instance
            .collection("books")
            .doc(widget.docment.id)
            .update({
          "name": _controllerName.text,
          "publisher": _controllerPublisher.text,
          "year": _controllerYear.text,
        });
      } else {
        await FirebaseFirestore.instance.collection("books").add({
          "name": _controllerName.text,
          "created_time": DateTime.now(),
          "publisher": _controllerPublisher.text,
          "year": _controllerYear.text,
          "status": 1,
        });
      }

      Navigator.pop(context);
    }
  }

  _handleSoftDelete() async {
    await FirebaseFirestore.instance
        .collection("books")
        .doc(widget.docment.id)
        .update({"status": 2});

    print("Object has been updated!");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form")),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                    controller: _controllerName,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Please check the name of the book";
                      }
                    },
                    decoration: InputDecoration(hintText: "Name")),
                TextFormField(
                    controller: _controllerPublisher,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Please check the publisher of the book";
                      }
                    },
                    decoration: InputDecoration(hintText: "Publisher")),
                TextFormField(
                    controller: _controllerYear,
                    keyboardType: TextInputType.number,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Please check the year of the book";
                      }
                    },
                    decoration: InputDecoration(hintText: "Year")),
                ElevatedButton(
                    onPressed: _handleSubmitAction, child: Text("Submit")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: _handleSoftDelete,
                    child: Text("Delete"))
              ],
            )),
      ),
    );
  }
}
