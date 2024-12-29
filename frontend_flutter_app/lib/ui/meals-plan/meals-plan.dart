import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/ui/meals-plan/edit-meal-screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Thư viện JSON
import 'package:http/http.dart' as http;

class MealsPlanScreen extends StatefulWidget {
  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealsPlanScreen> {
  // Danh sách các bữa ăn
  List<Map<String, dynamic>> _meals = []; // Lưu trữ tên bữa ăn và danh sách món ăn
  String? _lastSavedDate; // Thời gian lưu lần cuối

  @override
  void initState() {
    super.initState();
    _loadLastSavedData();
  }

  // Hàm định dạng ngày dưới dạng yyyy-MM-dd
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Hàm load thông tin lưu lần cuối
  Future<void> _loadLastSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSavedDate = prefs.getString('last_saved_date');
    final today = _formatDate(DateTime.now());

    // Kiểm tra xem lần lưu cuối có phải hôm nay không
    if (_lastSavedDate != today) {
      // Nếu không, đặt danh sách rỗng
      setState(() {
        _meals = [];
      });
    } else {
      // Nếu là hôm nay, gửi request GET để lấy thông tin từ server
      await _fetchMealData();
    }
  }

  // Gửi request GET đến server để lấy dữ liệu
  Future<void> _fetchMealData() async {
    try {
      final response = await http.get(Uri.parse('https://api.example.com/meals'));
      if (response.statusCode == 200) {
        final List<dynamic> mealsData = json.decode(response.body);
        setState(() {
          _meals = mealsData.map((meal) => {
            'mealTime': meal['mealTime'],
            'dishes': List<dynamic>.from(meal['dishes']), // Thay đổi kiểu dữ liệu thành List<dynamic>
          }).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Hàm lưu dữ liệu
  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());

    // Gửi request POST hoặc PUT
    if (_lastSavedDate != today) {
      // POST request nếu chưa có dữ liệu cho ngày hôm nay
      await _postMealData();
    } else {
      // PUT request nếu đã có dữ liệu cho ngày hôm nay
      await _putMealData();
    }

    // Cập nhật thời gian lưu lần cuối
    await prefs.setString('last_saved_date', today);
    setState(() {
      _lastSavedDate = today;
    });
  }

  // Gửi request POST để lưu dữ liệu mới
  Future<void> _postMealData() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.example.com/meals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_meals),
      );
      if (response.statusCode == 201) {
        print('Meals saved successfully');
      } else {
        throw Exception('Failed to save meals');
      }
    } catch (error) {
      print('Error saving data: $error');
    }
  }

  // Gửi request PUT để cập nhật dữ liệu
  Future<void> _putMealData() async {
    try {
      final response = await http.put(
        Uri.parse('https://api.example.com/meals'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_meals),
      );
      if (response.statusCode == 200) {
        print('Meals updated successfully');
      } else {
        throw Exception('Failed to update meals');
      }
    } catch (error) {
      print('Error updating data: $error');
    }
  }

  // Thêm bữa ăn
  void _addMeal() {
    setState(() {
      _meals.add({'mealTime': 'Bữa mới ${_meals.length + 1}', 'dishes': []});
    });
  }

  // Xóa bữa ăn
  void _deleteMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  // Chỉnh sửa bữa ăn
  void _editMeal(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMealScreen(
          mealTime: _meals[index]['mealTime'],
          dishes: _meals[index]['dishes'],
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _meals[index] = {
          'mealTime': result['mealTime'],
          'dishes': result['dishes'],
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dự định bữa ăn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _meals.length,
              itemBuilder: (context, index) {
                return MealItem(
                  mealTime: _meals[index]['mealTime'],
                  onDelete: () => _deleteMeal(index),
                  onTap: () => _editMeal(index), // Sửa lỗi gọi hàm _editMeal
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveMeals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Nút màu xanh
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MealItem extends StatelessWidget {
  final String mealTime;
  final VoidCallback onDelete;
  final VoidCallback onTap; // Thêm callback khi nhấn vào item

  const MealItem({
    super.key,
    required this.mealTime,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Kích hoạt callback khi nhấn
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mealTime,
              style: const TextStyle(fontSize: 16),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ];
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}