import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';

class AddDishScreen extends StatefulWidget {
  const AddDishScreen({Key? key}) : super(key: key);

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dishNameController = TextEditingController();
  final _dishContentController = TextEditingController();
  List<Map<String, dynamic>> _ingredients = [
    {'name': 'Thịt bò', 'quantity': '500g'},
    {'name': 'Hành tây', 'quantity': '1 củ'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Thêm công thức nấu ăn'),
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.person),
      //       onPressed: () {
      //         // TODO: Xử lý hành động khi nhấn vào icon người dùng
      //       },
      //     ),
      //   ],
      // ),
      appBar: const MyAppBar(title: "Thêm công thức nấu ăn"),
      body: SingleChildScrollView( // Cho phép cuộn khi nội dung quá dài
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Tên công thức',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _dishNameController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tên công thức của bạn',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên công thức';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nguyên liệu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ..._ingredients.asMap().entries.map((entry) { // Sử dụng asMap() để lấy index
                  final index = entry.key;
                  final ingredient = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: ingredient['name'],
                          decoration: const InputDecoration(
                            hintText: 'Tên nguyên liệu',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: ingredient['quantity'],
                          decoration: const InputDecoration(
                            hintText: 'Số lượng',
                          ),
                        ),
                      ),
                      if (_ingredients.length > 1) // Chỉ hiển thị nút (-) nếu có nhiều hơn 1 nguyên liệu
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _ingredients.removeAt(index); // Xóa nguyên liệu tại index
                            });
                          },
                        ),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Xử lý thêm nguyên liệu mới
                      setState(() {
                        _ingredients.add({'name': '', 'quantity': ''});
                      });
                    },
                    child: const Text('+'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nội dung công thức',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: _dishContentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Nhập nội dung công thức của bạn',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nội dung công thức';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Mô tả thêm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Mô tả thêm về công thức của bạn',
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Màu xanh lá cây
                      ),
                      onPressed: () {
                        // TODO: Xử lý lưu công thức
                        if (_formKey.currentState!.validate()) {
                          // Lưu dữ liệu vào cơ sở dữ liệu
                          // ...
                          // Sau khi lưu thành công, hiển thị thông báo hoặc điều hướng người dùng
                          final newDish = {
                            'name': _dishNameController.text,
                            'content': _dishContentController.text,
                            // ... các thông tin khác của món ăn
                          };

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm công thức')),
                          );
                          Navigator.pop(context, newDish);
                        }
                      },
                      child: const Text('Thêm công thức'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Màu đỏ
                      ),
                      onPressed: () {
                        // TODO: Xử lý hủy bỏ
                        Navigator.pop(context);
                      },
                      child: const Text('Hủy bỏ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}