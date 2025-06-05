class CepModel {
  final String id;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;
  final String cep;

  CepModel({
    required this.id,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
    required this.cep,
  });

  factory CepModel.fromMap(Map<String, dynamic> map) {
    return CepModel(
      id: map['id'],
      logradouro: map['logradouro'],
      bairro: map['bairro'],
      cidade: map['cidade'],
      uf: map['uf'],
      cep: map['cep'],
    );
  }
}
