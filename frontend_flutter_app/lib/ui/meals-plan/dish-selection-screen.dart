import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/ui/meals-plan/add-dish-screen.dart';

class DishSelectionScreen extends StatefulWidget {
  const DishSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DishSelectionScreen> createState() => _DishSelectionScreenState();
}

class _DishSelectionScreenState extends State<DishSelectionScreen> {
  List<Map<String, dynamic>> dishes = [
    // ... thêm dữ liệu món ăn từ cơ sở dữ liệu của bạn
  ];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredDishes = dishes.where((dish) {
      final name = dish['name'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn món ăn'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm món ăn...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredDishes.isNotEmpty
                ? ListView.builder(
              itemCount: filteredDishes.length,
              itemBuilder: (context, index) {
                final dish = filteredDishes[index];
                return ListTile(
                  title: Text(dish['name']),
                  onTap: () {
                    // TODO: Xử lý khi chọn món ăn
                    Navigator.pop(context, dish);
                  },
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Không tìm thấy món ăn'),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddDishScreen()),
                      );

                      // Kiểm tra kết quả trả về
                      if (result != null && result is Map<String, dynamic>) {
                        // Trả về dữ liệu món ăn mới cho EditMealScreen
                        Navigator.pop(context, result);
                      }

                    },
                    child: const Text('Thêm món ăn mới'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}