import 'package:flutter/material.dart';

import 'banco_dados/banco_de_dados.dart';
import 'models/contato.dart';
import 'paginas/cadastro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PaginaInicial(),
    );
  }
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  late Future<List<Contato>> _contatos;

  @override
  void initState() {
    super.initState();
    _carregarContatos();
  }

  void _carregarContatos() {
    _contatos = BancoDeDados.instance.selecionarContatos();
  }

  Future<void> _abrirCadastro({Contato? contato}) async {
    final salvo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => Cadastro(contato: contato)),
    );
    if (salvo == true && mounted) {
      setState(_carregarContatos);
    }
  }

  Future<void> _apagarContato(Contato contato) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar contato?'),
        content: Text('Deseja apagar ${contato.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) {
      return;
    }

    try {
      await BancoDeDados.instance.apagarContato(contato.id!);
      if (mounted) {
        setState(_carregarContatos);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível apagar o contato: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de Contatos')),
      body: FutureBuilder<List<Contato>>(
        future: _contatos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Não foi possível carregar os contatos: ${snapshot.error}',
                  ),
                ],
              ),
            );
          }

          final contatos = snapshot.data!;
          if (contatos.isEmpty) {
            return const Center(child: Text('Nenhum contato cadastrado.'));
          }

          return ListView.separated(
            itemCount: contatos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final contato = contatos[index];
              return ListTile(
                title: Text(contato.nome),
                subtitle: Text(contato.email),
                onTap: () => _abrirCadastro(contato: contato),
                trailing: IconButton(
                  tooltip: 'Apagar contato',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _apagarContato(contato),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar contato',
        onPressed: () => _abrirCadastro(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
