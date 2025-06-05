import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://fscmqnrosmzytqdamykz.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzY21xbnJvc216eXRxZGFteWt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyNjQ5NzQsImV4cCI6MjA2Mjg0MDk3NH0.4eUmHnngonwAq82YjT782iYRBnzHqz4p-x9YdbYPFGs';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }
}