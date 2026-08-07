import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() async {
  final url = 'https://lrmoxfjuhqesjoxjkftw.supabase.co/rest/v1/profiles';
  final key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxybW94Zmp1aHFlc2pveGprZnR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzMTY2NDUsImV4cCI6MjA2NDg5MjY0NX0.eROCpGbLqUU_4BsJzU7VJcmJcR-U7X2JRe-M3VHjJFk';
  final profiles = [
    {'id': '00000000-0000-0000-0000-000000000001', 'display_name': 'Layla', 'gender': 'female', 'birth_date': '1998-03-15', 'caste': 'murid', 'looking_for': 'heirat', 'city': 'Berlin', 'bio': 'Ich liebe Musik und Reisen'},
    {'id': '00000000-0000-0000-0000-000000000002', 'display_name': 'Narin', 'gender': 'female', 'birth_date': '1999-07-22', 'caste': 'pir', 'looking_for': 'heirat', 'city': 'Hamburg', 'bio': 'Auf der Suche nach dem Richtigen'},
    {'id': '00000000-0000-0000-0000-000000000003', 'display_name': 'Rojin', 'gender': 'female', 'birth_date': '1997-11-08', 'caste': 'scheich', 'looking_for': 'dating', 'city': 'Bielefeld', 'bio': 'Spontan und lebensfroh'},
    {'id': '00000000-0000-0000-0000-000000000004', 'display_name': 'Kardo', 'gender': 'male', 'birth_date': '1996-05-10', 'caste': 'murid', 'looking_for': 'heirat', 'city': 'Oldenburg', 'bio': 'Familiär und treu'},
    {'id': '00000000-0000-0000-0000-000000000005', 'display_name': 'Dijwar', 'gender': 'male', 'birth_date': '1995-09-03', 'caste': 'pir', 'looking_for': 'heirat', 'city': 'Hannover', 'bio': 'Suche eine ehrliche Partnerin'},
  ];
  for (final p in profiles) {
    final res = await http.post(Uri.parse(url),
      headers: {'apikey': key, 'Authorization': 'Bearer \$key', 'Content-Type': 'application/json', 'Prefer': 'resolution=merge-duplicates'},
      body: json.encode(p),
    );
    print('\${p['display_name']}: \${res.statusCode}');
  }
}
