import 'package:flutter/material.dart';

class ShoppingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Danh sách mua sắm"),
      ),
      body: Center(
        child: Text("Trang Danh sách mua sắm"),
      ),
    );
  }
}
