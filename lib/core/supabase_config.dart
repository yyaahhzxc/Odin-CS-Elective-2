/// Global configuration holding Supabase credentials.
class SupabaseConfig {
  /// Supabase project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://qvqlhswjmlnlolpnrqhu.supabase.co',
  );

  /// Supabase public anonymous/publishable API key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF2cWxoc3dqbWxubG9scG5ycWh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczNzEwMDgsImV4cCI6MjA5Mjk0NzAwOH0.ix2oRluqmQWJDh2RUdp-TnD7mkY0lJGPmCMLI3LvHrk',
  );

  /// Returns true if credentials have been populated with non-placeholder values.
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey.isNotEmpty &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
  }
}
