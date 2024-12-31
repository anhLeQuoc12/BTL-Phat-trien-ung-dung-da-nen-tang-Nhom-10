import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/constant.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/ui/shopping-list/add_shopping_list_screen.dart';
import 'package:frontend_flutter_app/ui/shopping-list/EditShoppingListScreen.dart';
import 'package:frontend_flutter_app/main.dart';

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late Future<List<Map<String, dynamic>>> _shoppingLists;

  @override
  void initState() {
    super.initState();
    _shoppingLists = fetchShoppingLists();
  }

  Future<List<Map<String, dynamic>>> fetchShoppingLists() async {
    String? token = await Auth.getAccessToken(); // Lấy token từ Auth package
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Token không hợp lệ")),
      );
      return [];
    }

    final response = await http.get(
      Uri.parse('http://${AppConstant.baseUrl}/api/list/getByUserId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Đảm bảo dữ liệu trả về chứa trường `data`
      if (jsonResponse.containsKey('data')) {
        final List<dynamic> data = jsonResponse['data'];

        // Lọc dữ liệu chỉ giữ lại các mục hợp lệ
        final validData = data.where((item) {
          if (item is! Map<String, dynamic>) return false;

          final content = item['content'];
          if (content is! Map<String, dynamic>) return false;

          // Kiểm tra `content` có chứa cả `name` và `items`
          if (!content.containsKey('name') || content['name'] is! String)
            return false;
          if (!content.containsKey('items') ||
              content['items'] is! List<dynamic>) return false;

          return true;
        }).toList();

        // Chuyển đổi dữ liệu hợp lệ thành List<Map<String, dynamic>>
        return validData.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected JSON structure');
      }
    } else {
      throw Exception('Failed to load shopping lists: ${response.statusCode}');
    }
  }

  Future<void> deleteShoppingList(String id) async {
    String? token = await Auth.getAccessToken(); // Lấy token từ Auth package
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token không hợp lệ")),
      );
      return;
    }

    final response = await http.delete(
      Uri.parse('http://${AppConstant.baseUrl}/api/list/$id/delete'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xóa danh sách thành công")),
      );
      // Cập nhật danh sách bằng cách xóa phần tử khỏi `_shoppingLists`
      setState(() {
        _shoppingLists = _shoppingLists.then(
          (lists) => lists.where((list) => list['_id'] != id).toList(),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xóa thất bại: ${response.body}")),
      );
    }
  }

  Future<void> shareShoppingList(String id) async {
    String? token = await Auth.getAccessToken(); // Lấy token từ Auth package
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token không hợp lệ")),
      );
      return;
    }

    final response = await http.patch(
      Uri.parse('http://${AppConstant.baseUrl}/api/list/$id/share'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final message = json.decode(response.body)["message"];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)), // Truyền message vào SnackBar
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Chia sẻ thất bại: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Danh sách mua sắm"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước
          },
        ),
      ),
      body: Column(
        children: [
          // Dòng chứa biểu tượng, văn bản và nút thêm
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      "Thêm danh sách",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.green),
                  onPressed: () {
                    // Chuyển tới màn hình AddShoppingListScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddShoppingListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _shoppingLists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có danh sách nào.'));
                } else {
                  final shoppingLists = snapshot.data!;
                  return ListView.builder(
                    itemCount: shoppingLists.length,
                    itemBuilder: (context, index) {
                      final list = shoppingLists[index];
                      final content = list['content'] as Map<String, dynamic>?;

                      final name = content?['name'] ?? 'Danh sách không tên';
                      final items =
                          (content?['items'] as List<dynamic>?) ?? <String>[];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          child: ExpansionTile(
                            title: Text(name),
                            leading: Icon(Icons.list, color: Colors.blue),
                            children: [
                              if (items.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Không có mục nào.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                ...items.map((item) => ListTile(
                                      title: Text(item.toString()),
                                    )),
                            ],
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () async {
                                    final updatedList = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditShoppingListScreen(
                                                shoppingList: list),
                                      ),
                                    );

                                    if (updatedList != null) {
                                      setState(() {
                                        // Cập nhật danh sách sau khi chỉnh sửa
                                        _shoppingLists = Future.value([
                                          ...snapshot.data!
                                            ..[index] = updatedList,
                                        ]);
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text("Xác nhận"),
                                          content: const Text(
                                              "Bạn có chắc muốn xóa danh sách này?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text("Hủy"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text("Xóa"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      await deleteShoppingList(list[
                                          '_id']); // Đảm bảo bạn truyền đúng `_id`
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.share, color: Colors.blue),
                                  onPressed: () async {
                                    await shareShoppingList(list['_id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData.light(),
    home: MyHomePage(title: "Ứng dụng đi chợ tiện lợi"),
  ));
}
