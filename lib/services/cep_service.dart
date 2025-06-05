import '../models/cep_model.dart';
import '../services/supabase_service.dart';

class CepService {
  final _client = SupabaseService.client;

  Future<List<CepModel>> fetchCeps({String? search}) async {
    final query = _client.from('ceps').select();

    if (search != null && search.isNotEmpty) {
      query.or('logradouro.ilike.%$search%,bairro.ilike.%$search%');
    }

    final data = await query;
    return (data as List).map((e) => CepModel.fromMap(e)).toList();
  }

  Future<CepModel?> getCepById(String id) async {
    final data = await _client.from('ceps').select().eq('id', id).single();
    return CepModel.fromMap(data);
  }
}
