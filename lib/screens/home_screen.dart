import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'favoritos_screen.dart';
import 'profile_screen.dart';
import 'cep_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  int _selectedIndex = 0;
  int totalFavoritos = 0;
  bool isLoading = true;

  final List<String> _titles = ['Início', 'Favoritos', 'Buscar CEP', 'Perfil'];

  final List<Widget> _screens = [
    Container(),
    const FavoritosScreen(),
    const CepDetailScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchFavoritoCount();
  }

  Future<void> _fetchFavoritoCount() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('favoritos')
          .select('id')
          .eq('usuario_id', user.id);
      setState(() {
        totalFavoritos = response.length;
        _screens[0] = _buildHomeTab();
        isLoading = false;
      });
    } else {
      setState(() {
        _screens[0] = _buildHomeTab();
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) async {
    if (index == 0) {
      setState(() => isLoading = true);
      await _fetchFavoritoCount();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() async {
    await supabase.auth.signOut();
  }

  Widget _buildHomeTab() {
    final user = supabase.auth.currentUser;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 6,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_city, size: 64, color: Colors.red.shade700),
                const SizedBox(height: 16),
                Text(
                  'Consulta de CEPs',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo ao aplicativo de consulta de CEPs de Santa Fé do Sul!',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                user != null
                    ? Column(
                        children: [
                          Text(
                            'Você tem',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '$totalFavoritos cidade(s) favorita(s).',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      )
                    : Text(
                        'Faça login para ver suas cidades favoritas.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red.shade700,
        unselectedItemColor: Colors.red.shade200,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar CEP'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}