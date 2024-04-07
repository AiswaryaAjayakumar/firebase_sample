// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, prefer_typing_uninitialized_variables

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drawer_sample1/view/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController c1 = TextEditingController();
  TextEditingController c2 = TextEditingController();
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("employees");

  var url;

  XFile? pickedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                    (route) => false);
              },
              icon: Icon(Icons.logout))
        ],
        leading: Builder(
            builder: (context) => IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.expand_more),
                )),
      ),
      // drawer: Drawer(
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //   elevation: 15,
      //   shadowColor: Colors.blue,
      //   // width: MediaQuery.sizeOf(context).width,
      //   backgroundColor: Colors.white54,
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       UserAccountsDrawerHeader(
      //           currentAccountPicture: CircleAvatar(
      //             backgroundImage: NetworkImage(
      //                 "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=800"),
      //             radius: 30,
      //           ),
      //           accountName: Text("Aishu"),
      //           accountEmail: Text("email")),
      //       Text("Home"),
      //       Text("Profile"),
      //       Text("Login"),
      //       Text("Home"),
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                pickedImage =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                // setState(() {});

                if (pickedImage != null) {
                  final uniqueImage =
                      DateTime.timestamp().microsecondsSinceEpoch.toString();
                  final storageRef = FirebaseStorage.instance.ref();
                  final imagesRef = storageRef.child("student");
                  final uploadRef = imagesRef.child("$uniqueImage");
                  await uploadRef.putFile(File(pickedImage!.path));
                  url = await uploadRef.getDownloadURL();
                  setState(() {});
                  if (url != null) {
                    log("image added successfully");

                    log(url.toString());
                  } else {
                    log("failed to upload image");
                  }
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.black,
                backgroundImage: url != null ? NetworkImage(url) : null,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: c1,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: c2,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  collectionReference
                      .add({"name": c1.text, "salary": c2.text, "image": url});
                },
                child: Text("Add")),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: StreamBuilder(
              stream: collectionReference.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Error");
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot emplSnap =
                            snapshot.data!.docs[index];
                        return ListTile(
                          leading: CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(
                                emplSnap["image"],
                              )),
                          title: Text(emplSnap["name"]),
                          subtitle: Text(emplSnap["salary"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  collectionReference.doc(emplSnap.id).set({
                                    "name": c1.text,
                                    "salary": c2.text,
                                  });
                                },
                                icon: Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () {
                                  collectionReference.doc(emplSnap.id).delete();
                                },
                                icon: Icon(Icons.delete),
                              )
                            ],
                          ),
                        );
                      });
                }
              },
            ))
          ],
        ),
      ),
    );
  }
}
