import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:frontend_flutter_app/ui/fridge/fridgeTab.dart';
// import 'package:frontend_flutter_app/ui/fridge/utils.dart';

class FridgeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(title: "Quản lý tủ lạnh"),
      body: const FridgeTab(),
    );
  }
}
