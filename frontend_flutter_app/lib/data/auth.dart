import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Auth {
  static String accessToken = "";

  static Future<void> getAccessTokenFromLocalDisk() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken") ?? "";
  }

  static Future<bool> authenticate() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("accessToken") ?? "";
    print(accessToken);
    final res = await http.get(Uri.parse("http://10.0.2.2:1000/api/auth"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    if (res.statusCode == 200) {
      print("authenticated");
      return true;
    } else {
      print("not authenticated");
      return false;
    }
  }
}
