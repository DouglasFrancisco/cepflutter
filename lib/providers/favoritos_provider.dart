import 'package:flutter/material.dart';
import '../models/favorito_model.dart';
import '../services/supabase_service.dart';

class FavoritosProvider extends ChangeNotifier {
  final _client = SupabaseService.client;
  List<FavoritoModel> favoritos = [];

  Future<void> fetchFavoritos() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final data = await _client
        .from('favoritos')
        .select()
        .eq('usuario_id', userId);

    favoritos = (data as List).map((e) => FavoritoModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addFavorito(String cepId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('favoritos').insert({
      'usuario_id': userId,
      'cep_id': cepId,
    });
    fetchFavoritos();
  }

  Future<void> removeFavorito(String favoritoId) async {
    await _client.from('favoritos').delete().eq('id', favoritoId);
    fetchFavoritos();
  }
}
