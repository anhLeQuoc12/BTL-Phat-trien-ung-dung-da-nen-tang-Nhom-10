import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_flutter_app/data/auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({super.key});

  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final oldPasswordInputController = TextEditingController();
  final newPasswordInputController = TextEditingController();
  final confirmPasswordInputController = TextEditingController();

  void changePassword() async {
    try {
      String oldPassword = oldPasswordInputController.text;
      String newPassword = newPasswordInputController.text;

      print(oldPassword);
      print(newPassword);

      if (newPassword != confirmPasswordInputController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mật khẩu mới và xác nhận mật khẩu không khớp')),
        );
        return;
      }

      final accessToken = await Auth.getAccessToken();

      final response = await http.put(
          Uri.parse('http://10.0.2.2:1000/api/user/password'),
          headers: <String, String>{
            "Content-type": "application/json; charset=UTF-8",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          },
          body: jsonEncode(<String, String>{
            "oldPassword": oldPassword,
            "newPassword": newPassword
          })
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đổi mật khẩu thành công')),
        );

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        print("Thất bại: ${response.body}");
        print("response code: ${response.statusCode}");
        throw Exception('Failed to change password');
      }
    }
    catch(error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(title: "Đổi mật khẩu"),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Mật khẩu cũ',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.visibility_off),
                          onPressed: () {}, // Hiện/ẩn mật khẩu
                        ),
                    ),
                    obscureText: true,
                    controller: oldPasswordInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập mật khẩu cũ";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.visibility_off),
                        onPressed: () {}, // Hiện/ẩn mật khẩu
                      ),
                    ),
                    obscureText: true,
                    controller: newPasswordInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng nhập mật khẩu mới";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.visibility_off),
                        onPressed: () {}, // Hiện/ẩn mật khẩu
                      ),
                    ),
                    obscureText: true,
                    controller: confirmPasswordInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng xác nhận mật khẩu mới";
                      }
                      return null;
                    },
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  changePassword();
                }
              },
              child: Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }


}



