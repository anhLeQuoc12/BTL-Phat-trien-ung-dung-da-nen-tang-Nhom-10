import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/data/auth.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final phoneInputController = TextEditingController();
  final passwordInputController = TextEditingController();

  void dispose() {
    phoneInputController.dispose();
    passwordInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Ứng dụng đi chợ tiện lợi"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(30),
            child: Text(
              "Đăng nhập",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 4),
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: "Số điện thoại"),
                    controller: phoneInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Số điện thoại không được bỏ trống";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 4, 10, 8),
                  child: TextFormField(
                    decoration: const InputDecoration(hintText: "Mật khẩu"),
                    controller: passwordInputController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Mật khẩu không được bỏ trống";
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await Auth.logIn(phoneInputController.text,
                            passwordInputController.text);
                        Navigator.pushReplacementNamed(context, "/home");
                      }
                    },
                    child: Text("Đăng nhập"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                        Navigator.pushNamed(context, "/register");
                        }
                    ,
                    child: Text("Đăng ký"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
