import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import the cloud_firestore package
import 'package:think_ninja_test/awaiting.dart';
import 'package:think_ninja_test/items.dart';
import 'package:think_ninja_test/orders.dart';
import 'package:think_ninja_test/preorder.dart';
import 'package:think_ninja_test/requests.dart';
import 'package:think_ninja_test/kitchen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Please use the sidebar to navigate'),
            const SizedBox(height: 40),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Orders')
                  .where('status', isEqualTo: 'Waiting for Collection')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                int ordersCount = snapshot.data!.docs.length;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Number of Orders:'),
                        Text('$ordersCount'), // Display the orders count
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      drawer: const MyDrawer(),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Ninja Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_sharp),
            title: const Text('Requests'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const request()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Orders()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.kitchen),
            title: const Text('Kitchen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KitchenPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Awaiting Collection'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Awaiting()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.food_bank),
            title: const Text('Menu'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Items()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.food_bank),
            title: const Text('Pre Order ( Coming Soon)'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const preOrder()),
              );
            },
          ),
        ],
      ),
    );
  }
}
