class FavoritoModel {
  final String id;
  final String usuarioId;
  final String cepId;

  FavoritoModel({required this.id, required this.usuarioId, required this.cepId});

  factory FavoritoModel.fromMap(Map<String, dynamic> map) {
    return FavoritoModel(
      id: map['id'],
      usuarioId: map['usuario_id'],
      cepId: map['cep_id'],
    );
  }
}