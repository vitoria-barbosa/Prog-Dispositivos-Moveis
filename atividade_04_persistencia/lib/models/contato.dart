class Contato {
  final int? id;
  final String nome;
  final String email;

  const Contato({this.id, required this.nome, required this.email});

  factory Contato.fromMap(Map<String, Object?> map) {
    return Contato(
      id: map['id'] as int,
      nome: map['nome'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {if (id != null) 'id': id, 'nome': nome, 'email': email};
  }
}
