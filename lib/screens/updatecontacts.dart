import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'contacts.dart';


class UpdateInfo extends StatefulWidget {
  final dynamic imageUrl;
  final dynamic contactData;
  final dynamic documentId;




  const UpdateInfo({Key? key, required this.imageUrl, required this.contactData,required this.documentId}) : super(key: key);

  @override
  State<UpdateInfo> createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfo> {

  final currentuser = FirebaseAuth.instance.currentUser!;

  File? _imageFile;


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
          CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(widget.imageUrl),
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


  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  var formKey = GlobalKey<FormState>();




  late final nametext = TextEditingController(text: widget.contactData['name']);
  late final contacttext = TextEditingController(text: widget.contactData['contact']);
  late final agetext = TextEditingController(text: widget.contactData['age']);
  late final birthdatetext = TextEditingController(text: widget.contactData['birthdate']);
  late final addresstext = TextEditingController(text: widget.contactData['address']);
  late final hobbiestext = TextEditingController(text: widget.contactData['hobbies']);


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

  String nameText = "";

  Future<void> updateFile() async {
    // Deleting the old image file
    Navigator.pop(context, MaterialPageRoute(builder: (context) => const HomePage()),);


    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentuser.uid)
        .collection('contacts')
        .doc(widget.documentId);

    dynamic url = '';

    if (_imageFile != null) {
      final ref =
      FirebaseStorage.instance.ref().child('users/${currentuser.uid}/${nametext.text}');
      url = await ref.putFile(_imageFile!).then((value) => value.ref.getDownloadURL());
    } else {
      url =  widget.imageUrl;
    }

    Map<String, dynamic> newData = {
      'name': nametext.text,
      'contact': contacttext.text,
      'age': agetext.text,
      'birthdate': birthdatetext.text,
      'address': addresstext.text,
      'hobbies': hobbiestext.text,
      'url': url,
    };

    await docRef.update(newData);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text('Update Contact Information'),
        elevation: 0,
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: [
            Center(child: _buildProfileImage()),
            const SizedBox(height: 20),

            TextFormField(
              controller: nametext,
              keyboardType: TextInputType.name,
              maxLength: 50,
              decoration:  InputDecoration(
                hintText: 'Ex: Kenn Vincent A. Nacario',
                labelText: 'Input Name',
                prefixIcon: Icon(Icons.phone),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter name' : null;
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
              controller: contacttext,
              keyboardType: TextInputType.number,
              maxLength: 11,
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
              keyboardType: TextInputType.number,
              maxLength: 2,
              decoration:  InputDecoration(
                hintText: 'Ex: 22',
                labelText: 'Input age',
                prefixIcon: Icon(Icons.phone),
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
              keyboardType: TextInputType.datetime,
              maxLength: 30,
              decoration:  InputDecoration(
                hintText: 'Ex: 02/02/2001',
                labelText: 'Input birthdate',
                prefixIcon: Icon(Icons.phone),
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
              keyboardType: TextInputType.name,
              maxLength: 50,
              decoration:  InputDecoration(
                hintText: 'Ex: Barra Opol, Misamis Oriental',
                labelText: 'Input address',
                prefixIcon: Icon(Icons.phone),
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
              keyboardType: TextInputType.name,
              maxLength: 50,
              decoration:  InputDecoration(
                hintText: 'Ex: ''[biking,fishing,cooking]''',
                labelText: 'Input hobbies',
                prefixIcon: Icon(Icons.phone),
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
              height: 25,
              child: ElevatedButton(
                onPressed: () async{
                  if (formKey.currentState!.validate()) {
                    await updateFile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully updated Contact!'),
                        backgroundColor: Colors.green,
                      ),
                    );

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
}



