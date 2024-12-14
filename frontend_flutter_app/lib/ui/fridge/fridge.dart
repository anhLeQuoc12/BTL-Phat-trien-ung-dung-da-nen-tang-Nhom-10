import 'package:flutter/material.dart';

class FridgeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Tủ lạnh"),
      ),
      body: Center(
        child: Text("Trang Tủ lạnh"),
      ),
    );
  }
}
