import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> favoritos = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFavoritos();
  }

  Future<void> fetchFavoritos() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          favoritos = [];
          loading = false;
          error = 'Usuário não está logado.';
        });
        return;
      }

      final response = await supabase
          .from('favoritos')
          .select('id, cep_id, ceps (cep, logradouro, bairro, cidade, uf)')
          .eq('usuario_id', user.id)
          .order('cep_id', ascending: true)
          .timeout(const Duration(seconds: 10));

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      setState(() {
        favoritos = data;
        loading = false;
        error = data.isEmpty ? 'Nenhum favorito encontrado.' : null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Erro ao buscar favoritos: $e';
      });
    }
  }

  Future<void> removeFavorito(String id) async {
    try {
      await supabase.from('favoritos').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removido dos favoritos!')),
      );
      fetchFavoritos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover favorito: $e')),
      );
    }
  }

  Widget buildFavoritoCard(Map<String, dynamic> favorito) {
    final cep = favorito['ceps'];
    if (cep == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red.shade100, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'CEP: ${cep['cep'] ?? 'Não informado'}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
            ),
            const Divider(height: 24, thickness: 1.2),
            buildInfoRow(Icons.location_on, 'Logradouro', cep['logradouro']),
            buildInfoRow(Icons.apartment, 'Bairro', cep['bairro']),
            buildInfoRow(Icons.location_city, 'Cidade', cep['cidade']),
            buildInfoRow(Icons.flag, 'Estado', cep['uf']),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => removeFavorito(favorito['id']),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
                label: const Text('Remover', style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.red.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value?.toString() ?? 'Não informado'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color.fromARGB(255, 239, 154, 154)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return buildEmptyState(error!, Icons.error_outline);
    }

    if (favoritos.isEmpty) {
      return buildEmptyState('Nenhum favorito encontrado.', Icons.favorite_border);
    }

    return Container(
      color: Colors.red.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: favoritos.length,
        itemBuilder: (context, index) {
          return buildFavoritoCard(favoritos[index]);
        },
      ),
    );
  }
}
