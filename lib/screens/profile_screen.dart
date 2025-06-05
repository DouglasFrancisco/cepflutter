import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config_profile_screen.dart' as config_profile;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  String? userEmail;
  String? cpf;
  String? cidade;
  String? bairro;
  String? rua;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentSession?.user;
    userEmail = user?.email;
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = supabase.auth.currentSession?.user;
    if (user == null) return;

    try {
      final response = await supabase
          .from('usuarios')
          .select('cpf, cidade, bairro, rua')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          cpf = response['cpf'];
          cidade = response['cidade'];
          bairro = response['bairro'];
          rua = response['rua'];
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  String formatarCpf(String cpf) {
    final numeros = cpf.replaceAll(RegExp(r'\D'), '');
    if (numeros.length != 11) return cpf;
    return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
  }

  Widget buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userEmail == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  userEmail![0].toUpperCase(),
                  style: TextStyle(fontSize: 32, color: Colors.red.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          buildInfo('Email', userEmail!),
          if (cpf != null) buildInfo('CPF', formatarCpf(cpf!)),
          if (cidade != null) buildInfo('Cidade', cidade!),
          if (bairro != null) buildInfo('Bairro', bairro!),
          if (rua != null) buildInfo('Rua', rua!),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Editar Dados do Perfil', style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const config_profile.ConfigProfileScreen()),
                ).then((_) => _carregarDadosUsuario());
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                elevation: 6,
                shadowColor: Colors.red.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}