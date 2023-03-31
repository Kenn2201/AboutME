

import 'package:aboutme/screens/addcontacts.dart';

import 'package:aboutme/screens/updatecontacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {


  const HomePage({Key? key,}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final currentuser = FirebaseAuth.instance.currentUser!;
  DatabaseReference db_Ref = FirebaseDatabase.instance.ref().child('contacts');
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;



  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(currentuser.uid)
        .collection('contacts')
        .snapshots();
  }


  Future<void> _deleteContact(String documentId,imageId) async {
    final currentuser1 = FirebaseAuth.instance.currentUser!;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentuser1.uid)
          .collection('contacts')
          .doc(documentId)
          .delete();


      await FirebaseStorage.instance
          .refFromURL(imageId)
          .delete()
          .then((_) => print('Image deleted successfully'))
          .catchError((error) => print('Failed to delete image: $error'));
      print('Contact deleted successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully Deleted Contact!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      print('Failed to delete contact: $error');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: const Text('Contacts'),
        elevation: 0,
      ),
      endDrawer: Drawer(
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.yellow,
                Colors.white60
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountEmail: Text('${currentuser.email!}'),
                accountName: Text('Signed in as:'),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: NetworkImage('https://example.com/profile-picture.jpg'),
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow , Colors.white60],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                otherAccountsPictures: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                    },
                  ),
                ],
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.question_mark),
                title: Text('About App'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('About App'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Developed by: Kenn Vincent A. Nacario'),
                            SizedBox(height: 8),
                            Text('App version: 1.5'),
                          ],
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );

                },

              ),

              Divider(color: Colors.grey,),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Log out'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully Logged-Out!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _stream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
            if (snapshot.hasError) {
              return const Text('Error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.requireData;
            if (data.size == 0) {
              return const Center(child: Text('No Contacts found'));
            }
            return RefreshIndicator(
                child: ListView.builder(
                    itemCount: data.size,
                    itemBuilder: (BuildContext context, int index){
                      final contact = data.docs[index].data();

                      final documentId = snapshot.data!.docs[index].id;

                      final contactData = data.docs[index].data();
                      final imageId = contact['url'];
                      final url = contact['url'];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          backgroundColor: Colors.yellow[400],
                          collapsedBackgroundColor: Colors.yellow[300],
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Colors.grey,
                             width: 1.0
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              contact['url']
                            ),
                          ),

                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(contact['name']),

                              ElevatedButton(
                                onPressed: () {
                                  print(url);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => UpdateInfo(imageUrl: url,contactData: contactData,documentId: documentId,))
                                  );
                                },
                                child: Text('Update'),
                              ),
                            ],
                          ),
                          subtitle: Text(contact['contact']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                          onPressed: (){
                            _deleteContact(documentId,imageId);
                          },
                          ),


                          children: <Widget>[
                            Column(
                              children: [
                                Center(
                                  child: CircleAvatar(
                                    radius: 100,
                                    backgroundImage: NetworkImage(
                                        contact['url']
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListTile(
                              title: Text('Name:'),
                              subtitle: Text(contact['name']),
                            ),
                            ListTile(
                              title: Text('Contact Number:'),
                              subtitle: Text(contact['contact']),
                            ),
                            ListTile(
                              title: Text('Age:'),
                              subtitle: Text(contact['age']),
                            ),
                            ListTile(
                              title: Text('Birthdate:'),
                              subtitle: Text(contact['birthdate']),
                            ),
                            ListTile(
                              title: Text('Address:'),
                              subtitle: Text(contact['address']),
                            ),
                            ListTile(
                              title: Text('Hobbies:'),
                              subtitle: Text(contact['hobbies']),
                            ),
                          ],
                        ),
                      );
                    }
                ),
                onRefresh: ()async{

                  setState(() {

                  });
                }
            );
          }
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: ()async{
          await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddInformation())
          );

        },
      ),
    );
  }
}

