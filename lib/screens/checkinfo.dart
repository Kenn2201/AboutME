

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CheckInfo extends StatelessWidget {
  const CheckInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final contactID = ModalRoute.of(context)!.settings.arguments as String;

    // Get the contact's document reference
    final contactDoc = FirebaseFirestore.instance.collection('contacts').doc(contactID);

    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text('Contact Information'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'From Section:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '3R-1',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),



    );
  }
}
