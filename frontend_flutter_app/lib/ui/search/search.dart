import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Tìm kiếm thực phẩm"),
      ),
      body: Center(
        child: Text("Trang Tìm kiếm thực phẩm"),
      ),
    );
  }
}
