import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> login() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Se já estiver cadastrado, apenas faz o login
        try {
          await _firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: senha,
          );
        } on FirebaseAuthException catch (e) {
          _mostrarErro(e.message ?? 'Erro ao entrar');
          return;
        }
      } else {
        _mostrarErro(e.message ?? 'Erro ao cadastrar');
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> loginComGoogle() async {
    final provider = GoogleAuthProvider();

    try {
      if (kIsWeb) {
        // No navegador abre um popup do Google
        await _firebaseAuth.signInWithPopup(provider);
      } else {
        // No Android abre a tela de login do Google
        await _firebaseAuth.signInWithProvider(provider);
      }
    } on FirebaseAuthException catch (e) {
      _mostrarErro(e.message ?? 'Erro ao entrar com o Google');
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("App Firebase")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(40),
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Se cadastre ou faça login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  label: Text('Email'),
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text('Senha'),
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                child: Text('Entrar'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  loginComGoogle();
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.deepPurple.shade100, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.black26,
                ),
                label: Text('Entrar com o Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
