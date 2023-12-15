import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Awaiting extends StatelessWidget {
  const Awaiting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awaiting Collection'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('status', isEqualTo: 'Waiting for Collection')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          List<DocumentSnapshot> documents = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> orderData =
                        documents[index].data() as Map<String, dynamic>;

                    String tableNumber = orderData['tableNumber'];
                    String menuItem = orderData['menuItem'];
                    int quantity = orderData['quantity'];
                    String status = orderData['status'];

                    if (status == 'Waiting for Collection') {
                      return Card(
                        child: ListTile(
                          title: Text('Table Number: $tableNumber'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Item: $menuItem'),
                              Text('Quantity: $quantity'),
                              Text('Status: $status'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              markAsCompleted(
                                  orderData, documents[index].reference);
                            },
                            child: const Text('Mark as Completed'),
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              // Back Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Back'),
              ),
            ],
          );
        },
      ),
    );
  }

  void markAsCompleted(
      Map<String, dynamic> orderData, DocumentReference reference) async {
    await FirebaseFirestore.instance.collection('PastOrders').add({
      'tableNumber': orderData['tableNumber'],
      'menuItem': orderData['menuItem'],
      'quantity': orderData['quantity'],
      'completedDate': Timestamp.now(),
    });

    await reference.delete();
  }
}
