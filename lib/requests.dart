import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class request extends StatefulWidget {
  const request({super.key});

  @override
  _requestState createState() => _requestState();
}

class _requestState extends State<request> {
  final TextEditingController tableNumberController = TextEditingController();
  final TextEditingController requestController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  List<String> menuItems = [];
  List<OrderItem> orderItems = [];

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
        'tableNumber': orderItem.tableNumber,
        'menuItem': orderItem.menuItem,
        'specialRequest': orderItem.specialRequest,
        'quantity': orderItem.quantity,
        'status': 'Placed',
      });
    }

    // Clear orderItems list
    setState(() {
      orderItems.clear();
    });

    print('ListView items sent to Firestore!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Table Number TextField
            TextField(
              controller: tableNumberController,
              decoration: const InputDecoration(labelText: 'Table Number'),
            ),
            const SizedBox(height: 16.0),

            // Menu Dropdown
            DropdownButtonFormField<String>(
              value: menuItems.isNotEmpty ? menuItems[0] : null,
              items: menuItems.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                // Handle menu item selection
                print('Selected Menu Item: $value');
              },
              decoration: const InputDecoration(labelText: 'Select Menu Item'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 16.0),
            // Requests TextField
            TextField(
              controller: requestController,
              decoration: const InputDecoration(labelText: 'Special Requests'),
            ),
            const SizedBox(height: 16.0),

            // Add to Order Button
            ElevatedButton(
              onPressed: () {
                // Add order information to the list
                String tableNumber = tableNumberController.text;
                String menuItem = menuItems.isNotEmpty ? menuItems[0] : '';
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
              child: const Text('Add Requests '),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: request(),
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
