import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:http/http.dart' as http;

class RecipeModel extends ChangeNotifier {
  final List<dynamic> _recipesList = [];

  Future<dynamic> getRecipesList() async {
    if (_recipesList.isEmpty) {
      final accessToken = await Auth.getAccessToken();
      final resFuture = http.get(Uri.parse("http://10.0.2.2:1000/api/recipe"),
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
      final waitForOneSecondFuture =
          Future.delayed(const Duration(seconds: 1), () {
        return "ok";
      });
      final res = (await Future.wait([resFuture, waitForOneSecondFuture]))[0]
          as http.Response;
      if (res.statusCode == 200) {
        final recipesList = jsonDecode(res.body);
        _recipesList.addAll(recipesList.reversed);
        return _recipesList;
      } else {
        throw Exception(
            "Đã có lỗi xảy ra trong quá trình tải danh sách các công thức nấu ăn của bạn.");
      }
    } else {
      return _recipesList;
    }
  }

  Future<dynamic> getRecipeById(String id) async {
    final accessToken = await Auth.getAccessToken();
    final resFuture = http.get(
        Uri.parse("http://10.0.2.2:1000/api/recipe/${id}"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    final waitForOneSecondFuture =
        Future.delayed(const Duration(seconds: 1), () {
      return "ok";
    });
    final res = (await Future.wait([resFuture, waitForOneSecondFuture]))[0]
        as http.Response;
    if (res.statusCode == 200) {
      final recipe = jsonDecode(res.body);
      return recipe;
    } else {
      throw Exception(
          "Đã có lỗi xảy ra trong quá trình tải công thức nấu ăn của bạn.");
    }
  }

  Future<String> addRecipe(
      String name, List ingredients, String content, String description) async {
    List sentToServerIngredients = [];
    for (int i = 0; i < ingredients.length; i++) {
      if (ingredients[i]["food"]["id"].isNotEmpty) {
        sentToServerIngredients.add({
          "foodId": ingredients[i]["food"]["id"],
          "quantity": ingredients[i]["quantity"]
        });
      }
    }
    List sentToServerContent = [];
    if (content.isNotEmpty) {
      sentToServerContent = content.split("\n");
    }
    List sentToServerDescription = [];
    if (description.isNotEmpty) {
      sentToServerDescription = description.split("\n");
    }
    final accessToken = await Auth.getAccessToken();
    final resFuture = http.post(Uri.parse("http://10.0.2.2:1000/api/recipe"),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
          HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8"
        },
        body: jsonEncode({
          "name": name.trim(),
          "ingredients": sentToServerIngredients,
          "content": sentToServerContent,
          "description": sentToServerDescription
        }));

    final waitForOneSecondFuture =
        Future.delayed(const Duration(seconds: 1), () {
      return "ok";
    });
    final res = (await Future.wait([resFuture, waitForOneSecondFuture]))[0]
        as http.Response;
    if (res.statusCode == 201) {
      final addedRecipeId = jsonDecode(res.body)["_id"];
      _recipesList.insert(0,
          {"_id": addedRecipeId, "name": name, "content": sentToServerContent});
      notifyListeners();
      return "Thêm công thức nấu ăn thành công.";
    } else {
      final message = jsonDecode(res.body)["message"];
      if (message.contains("has already existed")) {
        return "Tên công thức nấu ăn đã tồn tại.";
      } else {
        return "Đã có lỗi xảy ra trong quá trình thêm công thức nấu ăn được yêu cầu.";
      }
    }
  }

  Future<String> updateRecipeById(
      String id,
      String? newName,
      dynamic? newIngredients,
      String? newContent,
      String? newDescription) async {
    var sentToServerUpdateObject = {};
    if (newName != null) {
      sentToServerUpdateObject["newName"] = newName;
    }
    if (newIngredients != null) {
      List sentToServerIngredients = [];
      for (int i = 0; i < newIngredients.length; i++) {
        if (newIngredients[i]["food"]["id"].isNotEmpty) {
          sentToServerIngredients.add({
            "foodId": newIngredients[i]["food"]["id"],
            "quantity": newIngredients[i]["quantity"]
          });
        }
      }
      sentToServerUpdateObject["newIngredients"] = sentToServerIngredients;
    }
    if (newContent != null) {
      List sentToServerContent = [];
      if (newContent.isNotEmpty) {
        sentToServerContent = newContent.split("\n");
      }
      sentToServerUpdateObject["newContent"] = sentToServerContent;
    }
    if (newDescription != null) {
      List sentToServerDescription = [];
      if (newDescription.isNotEmpty) {
        sentToServerDescription = newDescription.split("\n");
      }
      sentToServerUpdateObject["newDescription"] = sentToServerDescription;
    }

    final accessToken = await Auth.getAccessToken();
    final resFuture = http.put(Uri.parse("http://10.0.2.2:1000/api/recipe/$id"),
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
          HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8"
        },
        body: jsonEncode(sentToServerUpdateObject));

    final waitForOneSecondFuture =
        Future.delayed(const Duration(seconds: 1), () {
      return "ok";
    });
    final res = (await Future.wait([resFuture, waitForOneSecondFuture]))[0]
        as http.Response;
    if (res.statusCode == 200) {
      for (int i = 0; i < _recipesList.length; i++) {
        if (_recipesList[i]["_id"] == id) {
          if (newName != null) {
            _recipesList[i]["name"] = newName;
          }
          if (newContent != null) {
            _recipesList[i]["content"] = sentToServerUpdateObject["newContent"];
          }
          break;
        }
      }
      notifyListeners();
      return "Sửa công thức nấu ăn thành công.";
    } else {
      final message = jsonDecode(res.body)["message"];
      if (message.contains("has already existed")) {
        return "Tên công thức nấu ăn đã tồn tại.";
      } else {
        return "Đã có lỗi xảy ra trong quá trình sửa công thức nấu ăn được yêu cầu.";
      }
    }
  }

  Future<String> deleteRecipeById(String id) async {
    final accessToken = await Auth.getAccessToken();
    final resFuture = http.delete(
        Uri.parse("http://10.0.2.2:1000/api/recipe/${id}"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    final waitForOneSecondFuture =
        Future.delayed(const Duration(seconds: 1), () {
      return "ok";
    });
    final res = (await Future.wait([resFuture, waitForOneSecondFuture]))[0]
        as http.Response;
    if (res.statusCode == 200) {
      _recipesList.removeWhere((recipe) => recipe["_id"] == id);
      notifyListeners();
      return "Xóa công thức nấu ăn thành công.";
    } else {
      return "Đã có lỗi xảy ra trong quá trình xóa công thức nấu ăn được yêu cầu.";

    }
  }

  Future<dynamic> connectRecipeWithFridge(String id) async {
    final accessToken = await Auth.getAccessToken();
    final resFuture = http.post(
        Uri.parse("http://10.0.2.2:1000/api/recipe/${id}/connect-with-fridge"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    final waitForOneSecondFuture =
        Future.delayed(const Duration(seconds: 1), () {
      return "ok";
    });
    final res = (await Future.wait([resFuture, waitForOneSecondFuture]))[0]
        as http.Response;
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return "Đã có lỗi xảy ra trong quá trình liên kết công thức nấu ăn với tủ lạnh.";

    }
  }
}
