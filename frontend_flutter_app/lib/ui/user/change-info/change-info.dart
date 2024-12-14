import 'package:flutter/material.dart';

class ChangeInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Thay đổi thông tin tài khoản"),
      ),
      body: Center(
        child: Text("Màn hình thay đổi tt tk"),
      ),
    );
  }
}
