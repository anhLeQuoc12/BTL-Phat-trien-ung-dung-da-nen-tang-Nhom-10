import 'dart:convert';
import 'package:frontend_flutter_app/constant.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:http/http.dart' as http;

class MealPlanService {
  static const String baseUrl = AppConstant.baseUrl+'/api'; // Thay thế bằng URL API của bạn

  static Future<http.Response> createMealPlan(
      String userId, DateTime date, String time, List<Map<String, dynamic>> recipes,
      {required String token}) async {
    token = await Auth.getAccessToken();
    final url = Uri.parse('$baseUrl/mealPlan'); // Thay 'mealplans' bằng endpoint thực tế
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token' // Thay thế bằng cách bạn thêm token vào header
    };
    final body = jsonEncode({
      'userId': userId,
      'date': date.toIso8601String(),
      'time': time,
      'recipes': recipes,
    });
    return http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> getAllMealPlansWithUserId(String userId,
      {required String token}) async {
    token = await Auth.getAccessToken();
    final url = Uri.parse('$baseUrl/mealPlan/$userId');
    final headers = {
      'Authorization': 'Bearer $token'
    };
    return http.get(url, headers: headers);
  }

  static Future<http.Response> getMealPlansWithUserIdAtTime(
      String userId, String time,
      {required String token}) async {
    token = await Auth.getAccessToken();
    final url = Uri.parse('$baseUrl/mealPlan/$userId/$time');
    final headers = {
      'Authorization': 'Bearer $token'
    };
    return http.get(url, headers: headers);
  }

  static Future<http.Response> getMealPlansWithUserIdAtDate(
      String userId, DateTime date,
      {required String token}) async {
    token = await Auth.getAccessToken();
    final url = Uri.parse('$baseUrl/mealPlan/$userId/${date.toIso8601String()}');
    final headers = {
      'Authorization': 'Bearer $token'
    };
    return http.get(url, headers: headers);
  }

  static Future<http.Response> updateMealPlan(String mealPlanId,
      {DateTime? newDate,
        String? newTime,
        List<Map<String, dynamic>>? newRecipes,
        required String token}) async {
    token = await Auth.getAccessToken();
    final url = Uri.parse('$baseUrl/mealPlan/$mealPlanId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({
      'newDate': newDate?.toIso8601String(),
      'newTime': newTime,
      'newRecipes': newRecipes,
    });
    return http.patch(url, headers: headers, body: body);
  }

  static Future<http.Response> deleteMealPlan(String mealPlanId,
      {required String token}) async {
    token = await Auth.getAccessToken();
    final url = Uri.parse('$baseUrl/mealPlan/$mealPlanId');
    final headers = {
      'Authorization': 'Bearer $token'
    };
    return http.delete(url, headers: headers);
  }
}