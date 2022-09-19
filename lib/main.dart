import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_firebase_firestore_example/form_page.dart';
import 'package:flutter_application_firebase_firestore_example/login_page.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Get.to(MyHomePage());
      } else {
        Get.to(LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
            "https://cdn.dribbble.com/users/528264/screenshots/3140440/firebase_logo.png"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? email;
  bool isVerified = true;
  SharedPreferences? prefs;
  _handleDeleteBook(book) async {
    await FirebaseFirestore.instance.collection("books").doc(book.id).delete();

    print("Object has been deleted!");
  }

  @override
  void initState() async {
    super.initState();

    email = FirebaseAuth.instance.currentUser!.email;
    isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    setSharedPreferences();
  }

  setSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  _handleSoftDelete(book) async {
    await FirebaseFirestore.instance
        .collection("books")
        .doc(book.id)
        .update({"status": 2});

    print("Object has been updated!");
  }

  _handleMovetoEdit(book) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FormPage(
                  docment: book,
                )));
  }

  _handleReactive(book) async {
    await FirebaseFirestore.instance
        .collection("books")
        .doc(book.id)
        .update({"status": 1});

    print("Object has been updated!");
  }

  _handleLogoutAction() {
    try {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Home Page"),
        actions: [
          IconButton(onPressed: _handleLogoutAction, icon: Icon(Icons.login)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FormPage()));
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        child: Column(
          children: [
            Visibility(
              visible: !isVerified,
              child: Container(
                height: 40,
                width: double.infinity,
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Please verify your email address",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        child: Text(
                          "Resend",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.currentUser!
                              .sendEmailVerification();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Text(
                  "Welcome $email",
                  style: TextStyle(fontSize: 20),
                )),
            Expanded(
              flex: 9,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("books")
                      .where("status", isEqualTo: 1)
                      // .where("userId",
                      //     isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .where("userId", isEqualTo: prefs!.getString("userId"))
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("There are an error occured"),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.connectionState == ConnectionState.active ||
                        snapshot.connectionState == ConnectionState.done) {
                      final data = snapshot.requireData;
                      return ListView.builder(
                          itemCount: data.size,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                                title: Text("${data.docs[index]['name']}"),
                                subtitle:
                                    Text("${data.docs[index]['publisher']}"),
                                leading: Text("${data.docs[index]['year']}"),
                                trailing: TextButton.icon(
                                  onPressed: () {
                                    // _handleDeleteBook(data.docs[index]);
                                    _handleMovetoEdit(data.docs[index]);
                                  },
                                  icon: Icon(Icons.edit),
                                  label: Text(
                                    "Edit",
                                  ),
                                ));
                          });
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
