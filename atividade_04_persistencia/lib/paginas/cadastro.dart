import 'package:flutter/material.dart';

import '../bd/banco_de_dados.dart';
import '../models/contato.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key, this.contato});

  final Contato? contato;

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  bool _salvando = false;

  bool get _editando => widget.contato != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.contato?.nome ?? '');
    _emailController = TextEditingController(text: widget.contato?.email ?? '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);

    final contato = Contato(
      id: widget.contato?.id,
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
    );

    try {
      if (_editando) {
        await BancoDeDados.instance.editarContato(contato);
      } else {
        await BancoDeDados.instance.criarContato(contato);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar o contato: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar contato' : 'Novo contato'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return 'Informe o e-mail';
                  }
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Informe um e-mail válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.deepPurple),
                  ),
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const CircularProgressIndicator()
                      : Text(
                          _editando ? 'Salvar alterações' : 'Salvar contato',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
