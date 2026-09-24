import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mercado App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<Item> items;

  HomePage({super.key})
    : items = [
        Item("Arroz", true),
        Item("Feijao", true),
        Item("Farinha", true),
      ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          color: Colors.white,
          onPressed: () {},
        ),
        title: Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_grocery_store),
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];
          return CheckboxListTile(
            activeColor: Colors.blue,
            title: Text(item.nome),
            key: Key(item.nome),
            value: item.isChecked,
            onChanged: (bool? value) {
              setState(() {
                item.isChecked = value ?? false;
              });
            },
          );
        },
      ),
    );
  }
}

class Item {
  String nome;
  bool isChecked;

  Item(this.nome, this.isChecked);
}
