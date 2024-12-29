import 'package:flutter/material.dart';

class EditMealScreen extends StatefulWidget {
  final String mealTime; // Bữa trong ngày (sáng, trưa, tối)
  final List<String> dishes; // Danh sách món ăn

  const EditMealScreen({super.key, required this.mealTime, required this.dishes});

  @override
  _EditMealScreenState createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  late String _selectedMealTime; // Lựa chọn bữa trong ngày
  late List<String> _dishes; // Danh sách món ăn

  @override
  void initState() {
    super.initState();
    _selectedMealTime = widget.mealTime;
    _dishes = List<String>.from(widget.dishes);
  }

  // Hàm thêm món ăn mới
  void _addDish() {
    setState(() {
      _dishes.add('Món mới ${_dishes.length + 1}');
    });
  }

  // Hàm xóa món ăn
  void _deleteDish(int index) {
    setState(() {
      _dishes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa bữa ăn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, {
              'mealTime': _selectedMealTime,
              'dishes': _dishes,
            }); // Trả dữ liệu về màn hình trước
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bữa trong ngày:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedMealTime,
              items: const [
                DropdownMenuItem(value: 'Sáng', child: Text('Sáng')),
                DropdownMenuItem(value: 'Trưa', child: Text('Trưa')),
                DropdownMenuItem(value: 'Tối', child: Text('Tối')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMealTime = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Danh sách món ăn:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _dishes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.food_bank),
                    title: Text(_dishes[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDish(index),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _addDish,
                child: const Text('Add Dish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
