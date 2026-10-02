import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gasolina VS Álcool',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.blue)),
      home: const MyHomePage(title: 'Gasolina VS Álcool'),
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
  final TextEditingController _valorGasolina = TextEditingController();
  final TextEditingController _valorAlcool = TextEditingController();
  String mensagem = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Gasolina VS Álcool', style: TextStyle(fontSize: 24)),
              Image.asset('foto_gasolina.jpg', width: 200, height: 200),
              Text(
                'Informe os valores da gasolina e do álcool:',
                style: TextStyle(fontSize: 18),
              ),

              TextField(
                controller: _valorGasolina,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor da Gasolina',
                ),
              ),

              TextField(
                controller: _valorAlcool,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor do Álcool'),
              ),

              ElevatedButton(
                onPressed: () {
                  double valorGasolina =
                      double.tryParse(_valorGasolina.text) ?? 0.0;
                  double valorAlcool =
                      double.tryParse(_valorAlcool.text) ?? 0.0;

                  if (valorGasolina == 0.0 || valorAlcool == 0.0) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Erro'),
                        content: Text('Por favor, insira valores válidos.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  double resultado = valorAlcool / valorGasolina * 100;

                  setState(() {
                    if (resultado <= 70) {
                      mensagem = 'Melhor abastecer com Álcool.';
                    } else {
                      mensagem = 'Melhor abastecer com Gasolina.';
                    }
                  });
                },
                child: Text('Calcular'),
              ),
              Text('Resultado: $mensagem', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
