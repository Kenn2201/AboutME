import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth/auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';






class AddInformation extends StatefulWidget {
  const AddInformation({Key? key}) : super(key: key);

  @override
  State<AddInformation> createState() => _AddInformationState();
}

class _AddInformationState extends State<AddInformation> {
  File? _imageFile;
  var url;
  String nameText = "";


  late DatabaseReference dbRef;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          CircleAvatar(
            backgroundImage: FileImage(_imageFile!),
            radius: 70,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Take a picture'),
                              onTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          const CircleAvatar(
            radius: 70,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera),
                              title: const Text('Take a picture'),
                              onTap: () {
                                _pickImage(ImageSource.camera);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from gallery'),
                              onTap: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    }
  }


  var formKey = GlobalKey<FormState>();

  final nametext = TextEditingController();
  final contacttext = TextEditingController();
  final agetext = TextEditingController();
  final birthdatetext = TextEditingController();
  final addresstext = TextEditingController();
  final hobbiestext = TextEditingController();
  final currentuser = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    contacttext.dispose();
    nametext.dispose();
    agetext.dispose();
    birthdatetext.dispose();
    addresstext.dispose();
    hobbiestext.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('contacts');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text('Add Contact Information'),
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            Center(child: _buildProfileImage()),
            SizedBox(height: 5),
            TextFormField(
              controller: nametext,
              maxLength: 50,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 5),
            TextFormField(
              controller: contacttext,
              maxLength: 11,
              keyboardType: TextInputType.number,
              decoration:  InputDecoration(
                hintText: 'Ex. 0997573XXXX',
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (idnum) {
                return (idnum == '')
                    ? 'Please enter a valid Phone Number'
                    : null;
              },
              onChanged: (value) {
                setState(() {
                  // Update the counter when the value changes
                  nameText = value;
                });
              },
            ),


            const SizedBox(height: 5),
            TextFormField(
              controller: agetext,
              maxLength: 2,
              keyboardType: TextInputType.number,
              decoration:  InputDecoration(
                hintText: 'Ex: 22',
                labelText: 'Input age',
                prefixIcon: Icon(Icons.perm_identity),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter age' : null;
              },
              onChanged: (value) {
                setState(() {
                  // Update the counter when the value changes
                  nameText = value;
                });
              },
            ),

            const SizedBox(height: 5),
            TextFormField(
              controller: birthdatetext,
              maxLength: 25,
              keyboardType: TextInputType.datetime,
              decoration:  InputDecoration(
                hintText: 'Ex: 02/02/2001',
                labelText: 'Input birthdate',
                prefixIcon: Icon(Icons.cake),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter birthdate' : null;
              },
              onChanged: (value) {
                setState(() {
                  // Update the counter when the value changes
                  nameText = value;
                });
              },
            ),

            const SizedBox(height: 5),
            TextFormField(
              controller: addresstext,
              maxLength: 50,
              keyboardType: TextInputType.name,
              decoration:  InputDecoration(
                hintText: 'Ex: Barra Opol, Misamis Oriental',
                labelText: 'Input address',
                prefixIcon: Icon(Icons.cases_outlined),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter address' : null;
              },
              onChanged: (value) {
                setState(() {
                  // Update the counter when the value changes
                  nameText = value;
                });
              },
            ),
            const SizedBox(height: 5),

            TextFormField(
              controller: hobbiestext,
              maxLength: 50,
              keyboardType: TextInputType.name,
              decoration:  InputDecoration(
                hintText: 'Ex: ''[biking,fishing,cooking]''',
                labelText: 'Input hobbies',
                prefixIcon: Icon(Icons.hourglass_bottom_outlined),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter hobbies' : null;
              },
              onChanged: (value) {
                setState(() {
                  // Update the counter when the value changes
                  nameText = value;
                });
              },
            ),

            const SizedBox(height: 5),
            SizedBox(
              height: 35,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    uploadFile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully Added Contact!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Submit'),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> uploadFile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not authenticated');
      return;
    }
    print('Current User UID: ${user.uid}');

    String url = '';
    if (_imageFile != null) {
      // Uploading the image file
      final storageRef = FirebaseStorage.instance.ref().child('users/${user.uid}/images/${nametext.text}');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      url = await snapshot.ref.getDownloadURL();
      print('Download URL: $url');
    }

    final collectionRef = FirebaseFirestore.instance.collection('users/${currentuser.uid}/contacts');
    final docRef = collectionRef.doc();

    await docRef.set({
      'name': nametext.text,
      'contact': contacttext.text,
      'age': agetext.text,
      'birthdate': birthdatetext.text,
      'address': addresstext.text,
      'hobbies': hobbiestext.text,
      'url': url,
    });
  }



}




