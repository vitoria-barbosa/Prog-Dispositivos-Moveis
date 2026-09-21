import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const MyHomePage(title: 'Home'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Color cor = Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      appBar: AppBar(backgroundColor: cor, title: Text(widget.title)),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: const EdgeInsets.only(top: 20),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(color: cor),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/foto_perfil.png'),
                    ),
                    SizedBox(height: 10),
                    Text('Nome do Usuário', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
            ListTile(title: const Text('Saldo'), onTap: () {}),
            ListTile(title: const Text('Extrato'), onTap: () {}),
            ListTile(title: const Text('Pagamentos'), onTap: () {}),
          ],
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            ListTile(title: const Text('Fazer pagamento'), onTap: () {}),
            ListTile(title: const Text('Ver histórico'), onTap: () {}),
            ListTile(title: const Text('Pedir cartão'), onTap: () {}),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
