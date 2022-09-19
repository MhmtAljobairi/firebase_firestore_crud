import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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
  String? _image;
  String? _filaName;

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
    User? user = FirebaseAuth.instance.currentUser;
    if (_formKey.currentState!.validate()) {
      if (widget.docment != null) {
        await FirebaseFirestore.instance
            .collection("books")
            .doc(widget.docment.id)
            .update({
          "name": _controllerName.text,
          "publisher": _controllerPublisher.text,
          "year": _controllerYear.text,
          "userId": user!.uid,
          "image": _image,
        });
      } else {
        await FirebaseFirestore.instance.collection("books").add({
          "name": _controllerName.text,
          "created_time": DateTime.now(),
          "publisher": _controllerPublisher.text,
          "year": _controllerYear.text,
          "status": 1,
          "userId": user!.uid,
          "image": _image,
        });
      }

      Navigator.pop(context);
    }
  }

  _handleUpload(ImageSource source) async {
    try {
      // 1- Pick up an Image.
      final ImagePicker _picker = ImagePicker();
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        // 2- Convert from XFile to normal File.
        File _file = File(photo!.path);

        // 2- Get file name.
        setState(() {
          _filaName = path.basename(_file.path);
        });

        // file.name => kejnerfeorfjerio
        //  path.basename => kejnerfeorfjerio.png
        // D:/image/camera/kejnerfeorfjerio.png

        // 4- Define an destination
        final destination = "images/$_filaName";
        // 5- Create ref. to Firebase Storage.
        final referance = FirebaseStorage.instance.ref(destination);
        // 6- Put a file into ref. and create it on Firebase.
        await referance.putFile(_file);

        _image = await referance.getDownloadURL();
        // 7- Close the Bottom Sheet.
        Navigator.pop(context);
      }
    } catch (ex) {
      Get.showSnackbar(GetSnackBar(
        title: ex.toString(),
      ));
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

  _handleSelectSource() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150,
            padding: EdgeInsets.all(12.0),
            child: ListView(children: [
              Text("Choose the way to capture the image"),
              ListTile(
                leading: Icon(Icons.camera),
                title: Text("Camera"),
                onTap: () async {
                  _handleUpload(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text("Gallery"),
                onTap: () {
                  _handleUpload(ImageSource.gallery);
                },
              ),
            ]),
          );
        });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: _handleSelectSource,
                        child: Text("Pick an image")),
                    Expanded(
                        flex: 1,
                        child: Text(
                          _filaName != null ? _filaName! : "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ))
                  ],
                ),
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
