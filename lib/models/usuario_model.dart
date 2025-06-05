class UsuarioModel {
  final String id;
  final String nome;
  final String cpf;
  final String cidade;
  final String bairro;
  final String rua;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.cidade,
    required this.bairro,
    required this.rua,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nome: map['nome'] ?? '',
      cpf: map['cpf'] ?? '',
      cidade: map['cidade'] ?? '',
      bairro: map['bairro'] ?? '',
      rua: map['rua'] ?? '',
    );
  }
}