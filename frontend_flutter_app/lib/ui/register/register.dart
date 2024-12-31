import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final usernameInputController = TextEditingController();
  final passwordInputController = TextEditingController();
  final confirmPasswordInputController = TextEditingController();
  final phoneInputController = TextEditingController();
  final mailInputController = TextEditingController();

  Future<void> register() async {
    try {
      final response = await http.post(
          Uri.parse('http://10.0.2.2:1000/api/user'),
          headers: <String, String>{
            "Content-type": "application/json; charset=UTF-8"
          },
          body: jsonEncode(<String, String>{
            "name": usernameInputController.text,
            "phone": phoneInputController.text,
            "email": mailInputController.text,
            "password": passwordInputController.text
          })
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo tài khoản thành công')),
        );

        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      } else {
        throw Exception('Failed to load data: ${response.body}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký tài khoản người dùng'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Tên người dùng *'),
                    controller: usernameInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Tên người dùng không được bỏ trống";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Mật khẩu *'),
                    controller: passwordInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Mật khẩu không được bỏ trống";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Xác nhận mật khẩu *'),
                    controller: confirmPasswordInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Vui lòng xác nhận mật khẩu";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Số điện thoại *'),
                    controller: phoneInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Số điện thoại không được bỏ trống";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    controller: mailInputController,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        register();
                      }
                    },
                    child: Text('Đăng ký'),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
