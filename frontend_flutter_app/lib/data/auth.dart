import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Auth {
  static String accessToken = "";
  static bool alreadyGetFromDisk = false;

  static Future<String> getAccessToken() async {
    if (alreadyGetFromDisk) {
      return accessToken;
    } else {
      final prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString("UDDCTL_Flutter_accessToken") ?? "";
      alreadyGetFromDisk = true;
      return accessToken;
    }
  }

  static Future<dynamic> authenticate() async {
    await getAccessToken();
    if (accessToken.isEmpty) {
      print("not authenticated");
      return "Not authenticated";
    } else {
      final res = await http.get(Uri.parse("http://10.0.2.2:1000/api/auth"),
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
      if (res.statusCode == 200) {
        print("authenticated");
        final result = jsonDecode(res.body);
        return result;
      } else {
        print("not authenticated");
        return "Not authenticated";
      }
    }
  }

  static Future<void> logIn(String phone, String password) async {
    final res = await http.post(
        Uri.parse("http://10.0.2.2:1000/api/auth/login"),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8"
        },
        body:
            jsonEncode(<String, String>{"phone": phone, "password": password}));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("UDDCTL_Flutter_accessToken", body["token"]);
      accessToken = body["token"];
    } else {
      print("Login failed");
      throw Error();
    }
  }

  static Future<void> deleteAccessTokenOnDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("UDDCTL_Flutter_accessToken");
    accessToken = "";
  }
}
