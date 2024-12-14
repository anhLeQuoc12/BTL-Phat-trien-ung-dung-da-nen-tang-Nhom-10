import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Đổi mật khẩu"),
      ),
      body: Center(
        child: Text("Màn hình thay đổi mk"),
      ),
    );
  }
}
