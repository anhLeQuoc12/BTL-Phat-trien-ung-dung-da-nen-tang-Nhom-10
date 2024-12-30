import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/ui/meals-plan/dish-selection-screen.dart';

class EditMealScreen extends StatefulWidget {
  final String mealTime;
  final List<dynamic> dishes;

  const EditMealScreen({super.key, required this.mealTime, required this.dishes});

  @override
  _EditMealScreenState createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  late String _selectedMealTime;
  late List<dynamic> _dishes;

  @override
  void initState() {
    super.initState();
    _selectedMealTime = widget.mealTime;
    _dishes = List<dynamic>.from(widget.dishes);
  }

  void _addDish() {
    setState(() {
      _dishes.add('Món mới ${_dishes.length + 1}');
    });
  }

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
            });
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
              items: [
                DropdownMenuItem(value: _selectedMealTime, child: Text(_selectedMealTime)),
                if (_selectedMealTime != 'Sáng') const DropdownMenuItem(value: 'Sáng', child: Text('Sáng')),
                if (_selectedMealTime != 'Trưa') const DropdownMenuItem(value: 'Trưa', child: Text('Trưa')),
                if (_selectedMealTime != 'Tối') const DropdownMenuItem(value: 'Tối', child: Text('Tối')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedMealTime = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Các món ăn dự định:', // Thay đổi text
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Hai cột
                  childAspectRatio: 2 / 1, // Điều chỉnh tỷ lệ khung hình của ô
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _dishes.length,
                itemBuilder: (context, index) {
                  final dish = _dishes[index];
                  return Card( // Sử dụng Card để tạo hiệu ứng nổi
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DishSelectionScreen(),
                          ),
                        );
                        if (result != null) {
                          // Cập nhật món ăn trong danh sách _dishes
                          setState(() {
                            _dishes[index] = result;
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              dish is String ? dish : dish.toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _deleteDish(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _addDish,
                child: const Text('Thêm món'), // Thay đổi text
              ),
            ),
          ],
        ),
      ),
    );
  }
}