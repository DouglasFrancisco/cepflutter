import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

class ConfigProfileScreen extends StatefulWidget {
  const ConfigProfileScreen({super.key});

  @override
  State<ConfigProfileScreen> createState() => _ConfigProfileScreenState();
}

class _ConfigProfileScreenState extends State<ConfigProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _cpfController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _bairroController = TextEditingController();
  final _ruaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosExistentes();
  }

  Future<void> _carregarDadosExistentes() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('usuarios')
          .select('cpf, cidade, bairro, rua')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _cpfController.text = response['cpf']?.toString() ?? '';
          _cidadeController.text = response['cidade'] ?? '';
          _bairroController.text = response['bairro'] ?? '';
          _ruaController.text = response['rua'] ?? '';
        });
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  Future<void> _salvarDados() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (_formKey.currentState!.validate()) {
      try {
        final String cpfLimpo = _cpfController.text.replaceAll(RegExp(r'\D'), '');
        await supabase.from('usuarios').upsert({
          'id': user.id,
          'nome': user.email ?? 'Usuário',
          'cpf': cpfLimpo,
          'cidade': _cidadeController.text.trim(),
          'bairro': _bairroController.text.trim(),
          'rua': _ruaController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados atualizados com sucesso!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.red.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value!.isEmpty ? 'Informe $label' : null,
      inputFormatters: formatters,
      keyboardType: keyboardType,
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    _ruaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Configurar Perfil'),
        backgroundColor: Colors.red.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField(
                controller: _cpfController,
                label: 'CPF',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              buildTextField(controller: _cidadeController, label: 'Cidade'),
              const SizedBox(height: 16),
              buildTextField(controller: _bairroController, label: 'Bairro'),
              const SizedBox(height: 16),
              buildTextField(controller: _ruaController, label: 'Rua'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _salvarDados,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Salvar Dados',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
