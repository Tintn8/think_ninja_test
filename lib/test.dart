import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:think_ninja_test/main.dart';

class test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: tester(),
      drawer: MyDrawer(),
    );
  }
}

class tester extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        // Filter orders with status "Waiting for Collection"
        List<Map<String, dynamic>> filteredOrders = documents
            .where((document) => document['status'] == 'Waiting for Collection')
            .map((document) => document.data() as Map<String, dynamic>)
            .toList();

        // Group orders by tableNumber
        Map<String, List<Map<String, dynamic>>> groupedOrders = {};

        for (Map<String, dynamic> order in filteredOrders) {
          String tableNumber = order['tableNumber'];

          if (!groupedOrders.containsKey(tableNumber)) {
            groupedOrders[tableNumber] = [];
          }

          groupedOrders[tableNumber]!.add(order);
        }

        return ListView.builder(
          itemCount: groupedOrders.length,
          itemBuilder: (context, index) {
            String tableNumber = groupedOrders.keys.elementAt(index);
            List<Map<String, dynamic>> orders = groupedOrders[tableNumber]!;

            return Card(
              child: ListTile(
                title: Text('Table Number: $tableNumber'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: orders
                      .map((order) => Text(
                            'Item: ${order['menuItem']} - Quantity: ${order['quantity']}',
                          ))
                      .toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Your MyDrawer class remains the same...
