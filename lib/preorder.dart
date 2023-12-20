// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: camel_case_types
class preOrder extends StatefulWidget {
  const preOrder({super.key});

  @override
  _preOrderState createState() => _preOrderState();
}

// ignore: camel_case_types
class _preOrderState extends State<preOrder> {
  final TextEditingController tableNumberController = TextEditingController();
  final TextEditingController requestController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  List<String> menuItems = [];
  List<OrderItem> orderItems = [];
  String selectedMenuItem = '';

  @override
  void initState() {
    super.initState();
    fetchMenuItems();
  }

  Future<void> fetchMenuItems() async {
    // Fetch menu items from Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('items').get();

    setState(() {
      menuItems = querySnapshot.docs
          .map((doc) => doc['description'] as String)
          .toList();
    });
  }

  Future<void> sendListViewItemsToFirestore() async {
    // Send order items from ListView to Firestore
    CollectionReference orders =
        FirebaseFirestore.instance.collection('requests');
    for (OrderItem orderItem in orderItems) {
      await orders.add({
        'tableNumber': 'Pre-Order',
        'menuItem': orderItem.menuItem,
        'specialRequest': orderItem.specialRequest,
        'quantity': orderItem.quantity,
        'status': 'Draft',
      });
    }

    // Clear orderItems list
    setState(() {
      orderItems.clear();
    });

    // print('ListView items sent to Firestore!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Table Number TextField

            // Menu Dropdown
            DropdownButtonFormField<String>(
              value: selectedMenuItem.isNotEmpty ? selectedMenuItem : null,
              items: menuItems.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                // Update the selectedMenuItem when the user selects a menu item
                setState(() {
                  selectedMenuItem = value ?? '';
                });
              },
              decoration: const InputDecoration(labelText: 'Select Menu Item'),
            ),

            const SizedBox(height: 16.0),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 12.0),
            // Requests TextField
            TextField(
              controller: requestController,
              decoration: const InputDecoration(labelText: 'Special Requests'),
            ),
            const SizedBox(height: 16.0),

            // Add to Order Button
            ElevatedButton(
              onPressed: () {
                // Use the selectedMenuItem instead of selecting the first item
                String tableNumber = tableNumberController.text;
                String menuItem =
                    selectedMenuItem; // Use the selectedMenuItem here
                String specialRequest = requestController.text;
                int quantity = int.tryParse(quantityController.text) ?? 1;

                OrderItem orderItem = OrderItem(
                  tableNumber: tableNumber,
                  menuItem: menuItem,
                  specialRequest: specialRequest,
                  quantity: quantity,
                  status: 'Draft',
                );

                setState(() {
                  orderItems.add(orderItem);
                });

                // Clear input fields
                tableNumberController.clear();
                quantityController.clear();
                requestController.clear();
              },
              child: const Text('Add to Order'),
            ),
            // Order Items ListView
            Expanded(
              child: ListView.builder(
                itemCount: orderItems.length,
                itemBuilder: (context, index) {
                  OrderItem orderItem = orderItems[index];

                  return ListTile(
                    title: Text(
                        '${orderItem.tableNumber}: ${orderItem.menuItem} - ${orderItem.specialRequest} - Quantity: ${orderItem.quantity}'),
                    onTap: () {
                      // Remove item from the order list
                      setState(() {
                        orderItems.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                sendListViewItemsToFirestore();
                tableNumberController.clear();
                requestController.clear();
              },
              child: const Text('Place Order '),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: preOrder(),
  ));
}

class OrderItem {
  final String tableNumber;
  final String menuItem;
  final String specialRequest;
  final int quantity;
  final String status;

  OrderItem({
    required this.tableNumber,
    required this.menuItem,
    required this.specialRequest,
    required this.quantity,
    required this.status,
  });
}
