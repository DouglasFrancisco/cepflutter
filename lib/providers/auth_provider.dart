import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient client = Supabase.instance.client;

  dynamic get user => client.auth.currentSession?.user;

  Future<bool> signIn(String email, String password) async {
    final res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    notifyListeners();
    return res.session != null && res.session!.user != null;
  }

  Future<bool> signUp(String email, String password) async {
    final res = await client.auth.signUp(
      email: email,
      password: password,
    );
    notifyListeners();
    return res.user != null;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
    notifyListeners();
  }
}