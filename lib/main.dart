import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_firebase_firestore_example/form_page.dart';

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _handleDeleteBook(book) async {
    await FirebaseFirestore.instance.collection("books").doc(book.id).delete();

    print("Object has been deleted!");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Home Page")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => FormPage()));
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("books")
              .where("status", isEqualTo: 1)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        subtitle: Text("${data.docs[index]['publisher']}"),
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
    );
  }
}
