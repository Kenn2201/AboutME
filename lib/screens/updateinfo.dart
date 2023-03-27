import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aboutme/models/models.dart';
import 'homepage.dart';


class UpdateInfo extends StatefulWidget {
  final dynamic imageUrl;




  const UpdateInfo({Key? key, required this.imageUrl,}) : super(key: key);

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

  var url;

  // Future<UserData> getUserData() async {
  //   final contactsRef = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(currentuser.uid)
  //       .collection('contacts')
  //       .get();
  //   final documentId = contactsRef.docs.first.id;
  //   final userDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(currentuser.uid)
  //       .collection('contacts')
  //       .doc(documentId)
  //       .get();
  //
  //
  //   return null
  // }


  late final nametext = TextEditingController();
  late final contacttext = TextEditingController();
  late final agetext = TextEditingController();
  late final birthdatetext = TextEditingController();
  late final addresstext = TextEditingController();
  late final hobbiestext = TextEditingController();


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



  Future<void> updateFile() async {
    if (_imageFile == null) {
      return;
    }

    // Uploading the image file
    final storageRef = FirebaseStorage.instance.ref().child('users/${currentuser.uid}/images/${nametext.text}');
    final uploadTask = storageRef.putFile(_imageFile!);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print('TEST DOWNLOAD URL : ${downloadUrl}');
    print(url);
    if (mounted) {
      setState(() {
        url = downloadUrl;
      });
    }
    await FirebaseStorage.instance
        .refFromURL(widget.imageUrl)
        .delete()
        .then((_) => print('Image deleted successfully'))
        .catchError((error) => print('Failed to delete image: $error'));

    // Fetching the document ID
    final contactsRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentuser.uid)
        .collection('contacts')
        .get();
    final documentId = contactsRef.docs.first.id;

    // Updating the contact document with new data
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentuser.uid)
        .collection('contacts')
        .doc(documentId);

    try {
      await docRef.update({
        'name': nametext.text,
        'contact': contacttext.text,
        'age': agetext.text,
        'birthdate': birthdatetext.text,
        'address': addresstext.text,
        'hobbies': hobbiestext.text,
        'url': downloadUrl.toString()
      });
    } catch (e) {
      // handle error
    }
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
          padding: const EdgeInsets.all(35),
          children: [
            Center(child: _buildProfileImage()),
            TextFormField(
              controller: nametext,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                hintText: 'Ex: Kenn Vincent A. Nacario',
                labelText: 'Input Name',
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter name' : null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: contacttext,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Ex. 0997573XXXX',
                labelText: 'Phone Number',
              ),
              validator: (idnum) {
                return (idnum == '')
                    ? 'Please enter a valid Phone Number'
                    : null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: agetext,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Ex: 22',
                labelText: 'Input age',
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter age' : null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: birthdatetext,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                hintText: 'Ex: 02/02/2001',
                labelText: 'Input birthdate',
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter birthdate' : null;
              },
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: addresstext,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                hintText: 'Ex: Barra Opol, Misamis Oriental',
                labelText: 'Input address',
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter address' : null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: hobbiestext,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                hintText: 'Ex: ''[biking,fishing,cooking]''',
                labelText: 'Input hobbies',
              ),
              validator: (idnum) {
                return (idnum == '') ? 'Please enter hobbies' : null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    updateFile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully updated Contact!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context, MaterialPageRoute(builder: (context) =>  const HomePage()));
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



