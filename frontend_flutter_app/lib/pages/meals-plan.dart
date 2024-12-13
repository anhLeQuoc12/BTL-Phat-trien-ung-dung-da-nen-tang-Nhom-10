import 'package:flutter/material.dart';

class MealsPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Dự định bữa ăn"),
      ),
      body: Center(
        child: Text("Trang Dự định bữa ăn"),
      ),
    );
  }
}
