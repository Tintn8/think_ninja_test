// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Items extends StatelessWidget {
  final CollectionReference itemsCollection =
      FirebaseFirestore.instance.collection('items');
  int documentCount = 0;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Items({super.key});

  // Function to add an item to Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16.0, width: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(
              height: 16.0,
              width: 10,
            ),
            TextField(
              controller: _priceController,
              decoration:
                  const InputDecoration(labelText: 'Price', prefixText: 'R'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                addItem();
              },
              child: const Text('Add Item'),
            ),
            Expanded(
              child: StreamBuilder(
                stream: itemsCollection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return InkWell(
                        onTap: () {
                          document.reference.delete();
                        },
                        child: ListTile(
                          title: Text(data['description']),
                          // ignore: prefer_interpolation_to_compose_strings
                          subtitle: Text('R' + data['price']),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addItem() async {
    try {
      String description = _descriptionController.text;
      String price = _priceController.text;
      int code = await getCount();
      await itemsCollection.add({
        'description': description,
        'price': price,
        'code': code.toString(),
      });
    } catch (e) {
      // print('Error adding item: $e');
    }
  }

  Future<int> getCount() async {
    try {
      CollectionReference collectionRef =
          FirebaseFirestore.instance.collection('items');

      QuerySnapshot querySnapshot = await collectionRef.get();

      int documentCount = querySnapshot.size;

      return documentCount;
    } catch (e) {
      // print('Error: $e');
      return 0;
    }
  }
}
