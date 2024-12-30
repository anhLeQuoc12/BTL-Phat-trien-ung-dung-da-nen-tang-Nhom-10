import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_flutter_app/data/auth.dart';

class AddShoppingListScreen extends StatefulWidget {
  @override
  _AddShoppingListScreenState createState() => _AddShoppingListScreenState();
}

class _AddShoppingListScreenState extends State<AddShoppingListScreen> {
  final TextEditingController listNameController = TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final List<String> items = [];
  bool isLoading = false;

  Future<void> _saveList() async {
    const String apiUrl = "http://${AppConstant.baseUrl}/api/list/create-list";

    // Lấy token từ Auth.getAccessToken() và sử dụng token làm userId
    String? token = await Auth.getAccessToken(); // Lấy token từ Auth package
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Token không hợp lệ")),
      );
      return;
    }

    if (listNameController.text.isEmpty || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập tên và thêm ít nhất một mục!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Gửi token trực tiếp trong header
        },
        body: json.encode({
          "content": {
            "name": listNameController.text,
            "items": items,
          },
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Danh sách đã được tạo thành công!")),
        );
        Navigator.pop(
            context, responseData['data']); // Trả danh sách về màn hình trước
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${responseData['error']}")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đã xảy ra lỗi khi gọi API: $error")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addItem() {
    if (itemController.text.isNotEmpty) {
      setState(() {
        items.add(itemController.text);
        itemController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm danh sách mua sắm"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, size: 40, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: listNameController,
                    decoration: InputDecoration(
                      labelText: "Tên danh sách mua sắm",
                      hintText: "Nhập tên danh sách mua sắm của bạn",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: itemController,
                    decoration: InputDecoration(
                      labelText: "Thêm thành phần",
                      hintText: "Nhập tên thực phẩm",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.blue),
                  onPressed: _addItem,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              "Nội dung danh sách",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]),
                  );
                },
              ),
            ),
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveList,
                      child: Text("Lưu danh sách"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Hủy"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
