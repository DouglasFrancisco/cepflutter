import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Auth App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.red.shade400,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      final user = session?.user;

      if (user != null) {
        await ensureUserInUsuariosTable(user.id, user.email);
      }

      setState(() {});
    });
  }

  Future<void> ensureUserInUsuariosTable(String userId, String? email) async {
    try {
      final existing =
          await supabase
              .from('usuarios')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (existing == null) {
        await supabase.from('usuarios').insert({
          'id': userId,
          'nome': email ?? 'Usuário',
        });
      }
    } catch (e) {
      debugPrint('Erro ao verificar/inserir usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;
    return session == null ? const LoginScreen() : const HomeScreen();
  }
}
