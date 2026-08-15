/// Public environment configuration for Bhagwa Mobile App.
/// NEVER store SUPABASE_SERVICE_ROLE_KEY or any private keys here.
class AppEnv {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fyhtlazvmvsdgsrndoxh.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5aHRsYXp2bXZzZGdzcm5kb3hoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4MTgzMzcsImV4cCI6MjEwMjM5NDMzN30.i3e68AmD6Aku5MTRAXwDt_pbytQrPZocFY1AsbT0YdI',
  );
}
