

import 'package:aboutme/screens/addinfo.dart';
import 'package:aboutme/screens/updateinfo.dart';
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
        title: const Text('About Me'),
        elevation: 0,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.yellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Signed in as:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${currentuser.email!}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Developed By:'),
              subtitle: Text(
                'Kenn Vincent A. Nacario',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('From Section:'),
              subtitle: Text(
                '3R-1',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Software Version'),
              subtitle: Text(
                '1.4',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            Divider(),
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

                            Center(
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: NetworkImage(
                                    contact['url']
                                ),
                              ),
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

