import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class users extends StatefulWidget {
  const users({super.key});

  @override
  State<users> createState() => _usersState();
}

class _usersState extends State<users> {
  var email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final CollectionReference myItems =
      FirebaseFirestore.instance.collection("Users");

  showUserData(DocumentSnapshot documentSnapshot) {
    return showDialog(
      barrierColor: Colors.black45,
      context: context,
      builder: (BuildContext context) {
        final userData = documentSnapshot;
        final name = userData['name'].toString();
        final email = userData['email'].toString();
        final phone = userData['phone'].toString();
        final pass = userData['password'].toString();
        final uid = userData["uid"].toString();
        var birthdate = userData['birthdate'].toString();
        var bio = userData['bio'].toString();

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Uid   : $uid"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Name : $name"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Email : $email"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Phone : ${phone == "" ? "No Number" : phone}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "BirthDate :  ${birthdate == "" ? "No birthdate" : birthdate}"),
              ),
              pass != ""
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Password :  $pass"),
                    )
                  : const Center(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Bio :  ${bio == "" ? "No Bio" : bio}"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final List<DocumentSnapshot> items =
                streamSnapshot.data!.docs.toList();
            return Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20)),
                height: 600,
                width: 400,
                child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot = items[index];
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                onTap: () {
                                  showUserData(documentSnapshot);
                                },
                                title: Text(
                                  documentSnapshot['name'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  documentSnapshot['email'],
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    try {
                                     if(documentSnapshot["password"] != null){
                                       final FirebaseAuth auth = FirebaseAuth.instance;
                                       await auth.signInWithEmailAndPassword(email: documentSnapshot["email"], password: documentSnapshot["password"]); // Use admin credentials
                                       print("${auth.currentUser}");
                                       FirebaseFirestore.instance.collection("Users").doc(documentSnapshot["uid"]).delete();
                                       await auth.currentUser!.delete() as User?;
                                       auth.signOut();
                                       print("Deleted Successfully");
                                     }
                                    } catch (e) {
                                      print("Not Deleted With ${e.toString()}");
                                    }
                                  },
                                  icon: Icon(Icons.delete_outline_sharp),
                                ),
                              ),
                            ),
                          ));
                    }),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
