// ignore_for_file: library_private_types_in_public_api, camel_case_types

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenPage extends StatelessWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen'),
      ),
      body: const kitchen_List(),
    );
  }
}

// ignore: camel_case_types
class kitchen_List extends StatefulWidget {
  const kitchen_List({super.key});

  @override
  _kitchenListState createState() => _kitchenListState();
}

class _kitchenListState extends State<kitchen_List> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                documents[index].data() as Map<String, dynamic>;

            String tableNumber = data['tableNumber'];
            String menuItem = data['menuItem'];
            int quantity = data['quantity'];
            String specialRequest = data['specialRequest'];
            String status = data['status'];

            // Add a condition to check if the status is "In Progress"
            if (status == 'In Progress') {
              return Card(
                child: ListTile(
                  title: Text('Table Number: $tableNumber'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Item: $menuItem'),
                      Text('Quantity: $quantity'),
                      Text('Special Instructions: $specialRequest'),
                      Text('Status: $status'),
                      Text('Table Number: $tableNumber'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Change the status to "Waiting for Collection"
                      changeStatus(documents[index].id);
                    },
                    child: const Text(' Completed'),
                  ),
                ),
              );
            } else {
              // If status is not "In Progress," return an empty container
              return Container();
            }
          },
        );
      },
    );
  }

  void changeStatus(String documentId) {
    FirebaseFirestore.instance.collection('Orders').doc(documentId).update({
      'status': 'Waiting for Collection',
    });
  }
}
