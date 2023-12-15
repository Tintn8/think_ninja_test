import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: const RequestList(),
    );
  }
}

class RequestList extends StatefulWidget {
  const RequestList({super.key});

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  // Map to track the editable state for each card
  Map<String, bool> isEditable = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('requests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        // Group documents by table number
        Map<String, List<DocumentSnapshot>> groupedByTable = {};
        for (var document in documents) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          if (data.containsKey('tableNumber')) {
            String tableNumber = data['tableNumber'];
            if (!groupedByTable.containsKey(tableNumber)) {
              groupedByTable[tableNumber] = [];
            }
            groupedByTable[tableNumber]!.add(document);
          }
        }

        return ListView.builder(
          itemCount: groupedByTable.length,
          itemBuilder: (context, tableIndex) {
            String tableNumber = groupedByTable.keys.elementAt(tableIndex);
            List<DocumentSnapshot> tableDocuments =
                groupedByTable[tableNumber]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Table Number: $tableNumber',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: tableDocuments.map((document) {
                    String documentId = document.id;
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    String menuItem = data['menuItem'];
                    int quantity = data['quantity'];
                    String specialRequest = data['specialRequest'];

                    return Card(
                      child: isEditable[documentId] == true
                          ? buildEditableCard(
                              tableNumber,
                              menuItem,
                              quantity,
                              specialRequest,
                              documentId,
                            )
                          : buildViewCard(
                              tableNumber,
                              menuItem,
                              quantity,
                              specialRequest,
                              documentId,
                            ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildViewCard(
    String tableNumber,
    String menuItem,
    int quantity,
    String specialRequest,
    String documentId,
  ) {
    return Column(
      children: [
        ListTile(
          title: Text('Item: $menuItem'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quantity: $quantity'),
              Text('Special Instructions: $specialRequest'),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Toggle to edit mode
                  isEditable[documentId] = true;
                });
              },
              child: const Text('Edit'),
            ),
            ElevatedButton(
              onPressed: () {
                // Delete the entry
                deleteEntry(documentId);
              },
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                // Push to the "Orders" collection and delete from "requests"
                pushToOrdersAndDelete(
                  tableNumber,
                  menuItem,
                  quantity,
                  specialRequest,
                  documentId,
                );
              },
              child: const Text('Push to Orders'),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildEditableCard(
    String tableNumber,
    String menuItem,
    int quantity,
    String specialRequest,
    String documentId,
  ) {
    return Column(
      children: [
        TextFormField(
          initialValue: menuItem,
          onChanged: (value) {
            // Update the menuItem when edited
            menuItem = value;
          },
          decoration: const InputDecoration(labelText: 'Item'),
        ),
        TextFormField(
          initialValue: quantity.toString(),
          onChanged: (value) {
            // Update the quantity when edited
            quantity = int.parse(value);
          },
          decoration: const InputDecoration(labelText: 'Quantity'),
        ),
        TextFormField(
          initialValue: specialRequest,
          onChanged: (value) {
            // Update the specialRequest when edited
            specialRequest = value;
          },
          decoration: const InputDecoration(labelText: 'Special Instructions'),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Save changes and toggle back to view mode
                  isEditable[documentId] = false;
                });
              },
              child: const Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                // Toggle back to view mode without saving changes
                setState(() {
                  isEditable[documentId] = false;
                });
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  void deleteEntry(String documentId) {
    FirebaseFirestore.instance.collection('requests').doc(documentId).delete();
  }

  void pushToOrders(String tableNumber, String menuItem, int quantity,
      String specialRequest) {
    FirebaseFirestore.instance.collection('Orders').add({
      'tableNumber': tableNumber,
      'menuItem': menuItem,
      'quantity': quantity,
      'specialRequest': specialRequest,
      'status': 'In Progress',
    });
  }

  void pushToOrdersAndDelete(
    String tableNumber,
    String menuItem,
    int quantity,
    String specialRequest,
    String documentId,
  ) {
    pushToOrders(tableNumber, menuItem, quantity, specialRequest);
    deleteEntry(documentId);
  }
}
