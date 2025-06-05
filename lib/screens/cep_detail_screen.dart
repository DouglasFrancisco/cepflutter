import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CepDetailScreen extends StatefulWidget {
  const CepDetailScreen({super.key});

  @override
  State<CepDetailScreen> createState() => _CepDetailScreenState();
}

class _CepDetailScreenState extends State<CepDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>>? searchedCeps;
  String? error;
  bool loading = false;

  int currentPage = 0;
  final int itemsPerPage = 20;
  List<Map<String, dynamic>> cepList = [];

  @override
  void initState() {
    super.initState();
    fetchCepPage();
  }

  Future<void> fetchCepPage() async {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage - 1;

    final response = await supabase
        .from('ceps')
        .select()
        .not('cep', 'is', null)
        .order('cep', ascending: true)
        .range(start, end);

    setState(() {
      cepList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> searchCep(String cep) async {
    setState(() {
      loading = true;
      error = null;
      searchedCeps = null;
    });

    try {
      final response = await supabase
          .from('ceps')
          .select()
          .eq('cep', cep)
          .limit(1)
          .single();

      setState(() {
        loading = false;
        searchedCeps = [Map<String, dynamic>.from(response)];
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Erro ao buscar CEP ou CEP não encontrado.';
      });
    }
  }

  Future<void> searchCepByRoad(String road) async {
    setState(() {
      loading = true;
      error = null;
      searchedCeps = null;
    });

    try {
      final termoFormatado = road.trim();
      final response = await supabase
          .from('ceps')
          .select()
          .ilike('logradouro', termoFormatado)
          .limit(30);

      setState(() {
        loading = false;
        searchedCeps = List<Map<String, dynamic>>.from(response);
        if (searchedCeps!.isEmpty) {
          error = 'Nenhuma rua encontrada com esse nome.';
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Erro ao buscar logradouro.';
      });
    }
  }

  Future<void> searchCepByBairro(String bairro) async {
    final String bairroFormatado = bairro.trim();

    if (bairroFormatado.isEmpty) {
      setState(() {
        error = 'Informe um bairro para buscar.';
        searchedCeps = null;
        loading = false;
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
      searchedCeps = null;
    });

    try {
      final response = await supabase
          .from('ceps')
          .select()
          .ilike('bairro', '%$bairroFormatado%')
          .limit(30);

      final List<Map<String, dynamic>> resultados =
          List<Map<String, dynamic>>.from(response);

      setState(() {
        loading = false;
        searchedCeps = resultados;
        if (resultados.isEmpty) {
          error = 'Nenhum CEP encontrado para esse bairro.';
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Erro ao buscar por bairro.';
      });
    }
  }

  Future<void> addToFavorites(Map<String, dynamic> cep) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final existingUser = await supabase
        .from('usuarios')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existingUser == null) {
      try {
        await supabase.from('usuarios').insert({
          'id': user.id,
          'nome': user.email ?? 'Usuário',
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao inserir usuário: $e')),
        );
        return;
      }
    }

    final existingFavorite = await supabase
        .from('favoritos')
        .select()
        .eq('usuario_id', user.id)
        .eq('cep_id', cep['id'])
        .maybeSingle();

    if (existingFavorite != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse CEP já está nos favoritos!')),
      );
      return;
    }

    try {
      await supabase.from('favoritos').insert({
        'usuario_id': user.id,
        'cep_id': cep['id'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicionado aos favoritos!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao favoritar: $e')),
      );
    }
  }

  Widget buildCepCard(Map<String, dynamic> cep) {
    final String? cepValue = cep['cep'];

    if (cepValue == null ||
        cepValue.toLowerCase().contains('n-one') ||
        !RegExp(r'^\d{5}-?\d{3}$').hasMatch(cepValue)) {
      return const SizedBox.shrink();
    }

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
                'CEP: $cepValue',
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
                onPressed: () => addToFavorites(cep),
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                label: const Text('Favoritar', style: TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Digite CEP, Logradouro ou Bairro',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      searchCep(_searchController.text.trim());
                    },
                    icon: const Icon(Icons.search),
                    label: const Text("Buscar por CEP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      searchCepByRoad(_searchController.text.trim());
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text("Por Logradouro"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  searchCepByBairro(_searchController.text.trim());
                },
                icon: const Icon(Icons.apartment_outlined),
                label: const Text("Buscar por Bairro"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (loading) const CircularProgressIndicator(),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            if (searchedCeps != null)
              ...searchedCeps!.map((cep) => buildCepCard(cep)).toList(),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Todos os CEPs:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            for (var cep in cepList) buildCepCard(cep),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentPage > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentPage--;
                      });
                      fetchCepPage();
                    },
                    child: const Text("Anterior"),
                  ),
                Text("Página ${currentPage + 1}"),
                if (cepList.length == itemsPerPage)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentPage++;
                      });
                      fetchCepPage();
                    },
                    child: const Text("Próxima"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
