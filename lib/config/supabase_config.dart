import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://teaawwipetvopcqmxpsj.supabase.co';
  // Note: Replace with your actual Supabase anon key from your project dashboard
  // This is a placeholder key structure - get the real key from Supabase project settings
  static const String supabaseAnonKey = 
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlYWF3d2lwZXR2b3BjcW14cHNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwMzU2NzYsImV4cCI6MjA1MDYxMTY3Nn0.vFTEmjjf_jWSK-zaPquzsw_8PtVCYXQ';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
