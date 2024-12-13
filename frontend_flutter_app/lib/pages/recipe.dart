import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Công thức nấu ăn"),
      ),
      body: Center(
        child: Text("Trang công thức nấu ăn"),
      ),
    );
  }
}
