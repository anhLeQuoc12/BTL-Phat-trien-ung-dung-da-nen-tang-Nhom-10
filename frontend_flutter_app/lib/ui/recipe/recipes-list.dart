import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/constant.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:frontend_flutter_app/ui/drawer.dart';
import 'package:http/http.dart' as http;

class RecipesListScreen extends StatelessWidget {
  Future<void> getRecipesList() async {
    final accessToken = await Auth.getAccessToken();
    final res = await http.get(Uri.http(AppConstant.baseUrl, '/api/recipe'),
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    print(res.body);
  }

  @override
  Widget build(BuildContext context) {
    getRecipesList();
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(title: "Công thức nấu ăn"),
      drawer: const MyAppDrawer(),
      body: Center(
        child: Text("Màn hình ct nấu ăn"),
      ),
    );
  }
}
