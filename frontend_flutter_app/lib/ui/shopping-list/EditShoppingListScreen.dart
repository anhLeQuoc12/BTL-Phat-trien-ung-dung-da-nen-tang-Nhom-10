import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter_app/data/auth.dart';

class EditShoppingListScreen extends StatefulWidget {
  final Map<String, dynamic> shoppingList;

  const EditShoppingListScreen({required this.shoppingList, Key? key})
      : super(key: key);

  @override
  _EditShoppingListScreenState createState() => _EditShoppingListScreenState();
}

class _EditShoppingListScreenState extends State<EditShoppingListScreen> {
  late Map<String, dynamic> _editableContent;
  late List<String> _items;
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _editableContent =
        Map<String, dynamic>.from(widget.shoppingList['content']);
    _items = List<String>.from(_editableContent['items'] ?? []);

    // Tạo TextEditingController cho các trường
    _editableContent.forEach((key, value) {
      if (key != 'items') {
        _controllers[key] = TextEditingController(text: value?.toString());
      }
    });
  }

  @override
  void dispose() {
    // Hủy TextEditingController để tránh rò rỉ bộ nhớ
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    // Cập nhật các giá trị từ controller vào _editableContent
    _controllers.forEach((key, controller) {
      _editableContent[key] = controller.text;
    });

    _editableContent['items'] = _items;

    final updatedList = {
      ...widget.shoppingList,
      'content': _editableContent,
    };

    String? token = await Auth.getAccessToken(); // Lấy token từ Auth package
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token không hợp lệ")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final listId = widget.shoppingList["_id"];
      final response = await http.put(
        Uri.parse('http://localhost:1000/api/list/$listId/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': _editableContent}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật danh sách thành công")),
        );
        Navigator.pop(context, updatedList); // Trả danh sách đã cập nhật
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${response.statusCode}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa danh sách'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Hiển thị các trường trong `content` (trừ `items`)
                  ..._editableContent.entries
                      .where((entry) => entry.key != 'items')
                      .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _controllers[entry.key],
                        decoration: InputDecoration(labelText: entry.key),
                        onChanged: (value) {
                          setState(() {
                            _editableContent[entry.key] = value;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  // Hiển thị danh sách `items`
                  const Text(
                    'Các mục trong danh sách:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ..._items.asMap().entries.map((entry) {
                    int index = entry.key;
                    String item = entry.value;
                    return ListTile(
                      title: TextField(
                        controller: TextEditingController(text: item),
                        onChanged: (value) {
                          setState(() {
                            _items[index] = value;
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _items.removeAt(index);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _items.add('');
                });
              },
              child: const Text('Thêm mục'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Lưu thay đổi'),
        ),
      ),
    );
  }
}
