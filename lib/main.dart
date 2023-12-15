import 'package:flutter/material.dart';
import 'package:think_ninja_test/items.dart';
import 'package:think_ninja_test/orders.dart';
import 'package:think_ninja_test/requests.dart';
import 'package:think_ninja_test/kitchen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:think_ninja_test/test.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome '),
      ),
      drawer: const MyDrawer(), // Using the MyDrawer class for the drawer
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
            leading: const Icon(Icons.restaurant),
            title: const Text('Orders'),
            onTap: () {
              // Handle drawer item tap for Settings
              Navigator.pop(context); // Close the drawer
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
              // Handle drawer item tap for Info
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KitchenPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.food_bank),
            title: const Text('Menu'),
            onTap: () {
              // Handle drawer item tap for Info
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Items()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Requests'),
            onTap: () {
              // Handle drawer item tap for Info
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => request()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('test'),
            onTap: () {
              // Handle drawer item tap for Info
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => test()),
              );
            },
          )
        ],
      ),
    );
  }
}
