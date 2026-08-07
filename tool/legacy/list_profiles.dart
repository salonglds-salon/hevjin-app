import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() async {
  final url = 'https://lrmoxfjuhqesjoxjkftw.supabase.co/rest/v1/profiles?select=id,display_name';
  final response = await http.get(Uri.parse(url), headers: {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxybW94Zmp1aHFlc2pveGprZnR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzMTY2NDUsImV4cCI6MjA2NDg5MjY0NX0.eROCpGbLqUU_4BsJzU7VJcmJcR-U7X2JRe-M3VHjJFk',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxybW94Zmp1aHFlc2pveGprZnR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkzMTY2NDUsImV4cCI6MjA2NDg5MjY0NX0.eROCpGbLqUU_4BsJzU7VJcmJcR-U7X2JRe-M3VHjJFk',
  });
  print(response.body);
}
