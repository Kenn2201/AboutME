import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'homepage.dart';


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

  var url;


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



  Future<void> updateFile() async {
    // Deleting the old image file
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const HomePage()));


    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentuser.uid)
        .collection('contacts')
        .doc(widget.documentId);
    try {
      Map<String, dynamic> newData = {
        'name': nametext.text,
        'contact': contacttext.text,
        'age': agetext.text,
        'birthdate': birthdatetext.text,
        'address': addresstext.text,
        'hobbies': hobbiestext.text,
      };

      if (_imageFile != null) {
        await FirebaseStorage.instance
            .refFromURL(widget.imageUrl)
            .delete()
            .then((_) => print('Old image deleted successfully'))
            .catchError((error) =>
            print('Failed to delete old image: $error'));

        // Uploading the new image file
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${currentuser.uid}/images/${nametext.text}');
        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        newData['url'] = downloadUrl.toString();

      }

      await docRef.update(newData);
      print('Contact data updated successfully');

    } catch (e) {
      print('Failed to update contact data: $e');
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



