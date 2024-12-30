import 'dart:convert';
import 'dart:io';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/auth.dart';
import '../drawer.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> categories = [];
  List<dynamic> categoriesData = [];
  Map<String, List<String>> products = {};
  Map<String, List> productsData = {};
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  String? categoryId;
  String? unitId;
  List<dynamic> units = [];


  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchUnits();
  }
  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      categories = [];
      categoriesData = [];
      products = {};
      productsData = {};
    });
    await _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    var token = await Auth.getAccessToken();

    try {
      final res1 = await http.get(
        Uri.parse('http://10.0.2.2:1000/api/admin/category'),
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      );

      if (res1.statusCode == 200) {
        List<dynamic> categoryList = List.from(jsonDecode(res1.body));

        if (mounted) {
          setState(() {
            categories = categoryList.map((category) => category['name'] as String).toList();
            categoriesData = categoryList;
          });
        }

        // Fetch sản phẩm cho từng danh mục
        for (var category in categoryList) {
          String categoryId = category['_id'];
          final res2 = await http.get(
            Uri.parse('http://10.0.2.2:1000/api/food/category/$categoryId'),
            headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
          );

          if (res2.statusCode == 200) {
            List<dynamic> productList = List.from(jsonDecode(res2.body));

            if (mounted) {
              setState(() {
                products[category['name']] = productList.map((product) => product['name'] as String).toList();
                productsData[category['name']] = productList.toList();
              });
            }
          }
        }

        // Khởi tạo TabController khi danh mục đã được tải xong
        _tabController = TabController(length: categories.length, vsync: this);
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quản lý thực phẩm",
              ),
              Image(
                image: AssetImage("assets/fridge.png"),
                width: 30,
                height: 30,
              ),
            ],
          ),
          centerTitle: true,
        ),
        drawer: const MyAppDrawer(),
        floatingActionButton: FloatingActionButton(onPressed: ()=>showPutItem(context,'add','') ,
          tooltip: 'Thêm thức ăn',child: const Icon(Icons.add), ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor:
                      Theme.of(context).colorScheme.inversePrimary,
                      tabs: categories
                          .map((category) => Tab(text: category))
                          .toList(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      _showAllCategories(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: EasyRefresh(onRefresh:()=> _onRefresh() ,child: TabBarView(
                controller: _tabController,
                children: categories.map((category) {
                  return _buildCategoryContent(
                      category, products[category] ?? []);
                }).toList(),
              ),),
            ),
          ],
        )
    );
  }

  Widget _buildCategoryContent(String category, List<String> items) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: ListTile(
              onTap: () {
                _showDetailItem(context, items[index], category);
              },
              leading: const Icon(Icons.fastfood),
              title: Text(items[index]),
              subtitle: Text("Sản phẩm thuộc danh mục $category"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _confirmDeleteItem(context, items[index], index, category);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _addCategory(context);
                    },
                    child: const Row(
                      children: [Text('Thêm'), Icon(Icons.add)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                        index.isEven ? Colors.grey.shade200 : Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        title: Text(
                          categories[index],
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteCate(context, categories[index]);
                          },
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _tabController.animateTo(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDetailItem(BuildContext context, item, category) {
    final product = productsData[category]?.firstWhere(
          (e) => e['name'] == item,
      orElse: () => null,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Chi tiết sản phẩm',
            style: TextStyle(fontSize: 20),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên sản phẩm: ${item}'),
                Text('Đơn vị: ${product['unitId']['name']}'),
                Text('Loại: ${product['categoryId']['name']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                showPutItem(context, 'update',item);
              },
              child: const Text('Cập nhật'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

// Hàm hiển thị hộp thoại xác nhận xóa
  void _confirmDeleteCate(BuildContext context, name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa danh mục này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                // Gọi API xóa danh mục
                _deleteCategory(context, name);
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteItem(BuildContext context, item, idx, category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                // Gọi API xóa danh mục
                _deleteCategoryItem(context, item, idx, category);
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
  void showPutItem(BuildContext context, String type, name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${type == 'add' ? 'Thêm mới' : 'Cập nhật'} sản phẩm'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nhập tên sản phẩm
                if(type=='add')TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên sản phẩm',
                    hintText: 'Nhập tên sản phẩm',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                // Chọn danh mục sản phẩm
                DropdownButtonFormField<String>(
                  value: categoryId,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: categoriesData.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category['_id'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      categoryId = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Chọn danh mục' : null,
                ),
                const SizedBox(height: 20),
                // Chọn đơn vị
                DropdownButtonFormField<String>(
                  value: unitId,
                  decoration: const InputDecoration(labelText: 'Đơn vị'),
                  items: units.map<DropdownMenuItem<String>>((unit) {
                    return DropdownMenuItem<String>(
                      value: unit['_id'],
                      child: Text(unit['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      unitId = value!;
                    });
                  },
                  validator: (value) => value == null ? 'Chọn đơn vị' : null,
                ),
                const SizedBox(height: 20),
                // Nhập URL hình ảnh (không bắt buộc)
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: 'URL hình ảnh (Không bắt buộc)',
                    hintText: 'Nhập URL hình ảnh',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                // Kiểm tra dữ liệu trước khi gọi API
                if (_validateFields(type)) {
                  // Gọi API thêm hoặc cập nhật sản phẩm
                  _putItem(context, type, name);
                }
              },
              child: Text(type == 'add' ? 'Thêm mới' : 'Cập nhật'),
            ),
          ],
        );
      },
    );
  }


// Hàm gọi API xóa danh mục
  Future<void> _deleteCategory(BuildContext context, name) async {
    var token = await Auth.getAccessToken();
    final id = categoriesData.firstWhere(
          (item) => item["name"] == name,
      orElse: () => null,
    )?["_id"];
    await http.delete(Uri.parse('http://10.0.2.2:1000/api/admin/category/$id'),
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    setState(() {
      categories.remove(name);
    });
    Navigator.pop(context);
  }

  Future<void> _deleteCategoryItem(
      BuildContext context, item, idx, category) async {
    var token = await Auth.getAccessToken();
    final id = categoriesData.firstWhere(
          (item) => item["name"] == item,
      orElse: () => null,
    )?["_id"];
    await http.delete(Uri.parse('http://10.0.2.2:1000/api/admin/food/${id}'), headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    setState(() {
      products[category]?.remove(item);
    });
  }

  void _addCategory(BuildContext context) {
    TextEditingController categoryController = TextEditingController();

    // Hiển thị dialog để nhập danh mục mới
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nhập danh mục mới'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(
              hintText: 'Tên danh mục mới',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Đóng dialog mà không làm gì cả
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                String newCategory = categoryController.text.trim();
                var token = await Auth.getAccessToken();

                // Kiểm tra xem người dùng đã nhập tên danh mục chưa
                if (newCategory.isNotEmpty) {
                  await http.post(Uri.parse('http://10.0.2.2:1000/api/admin/category'), headers: {HttpHeaders.authorizationHeader: "Bearer $token"}, body: {
                    'name': newCategory,
                  });
                  setState(() {
                    categories.add(newCategory);  // Thêm danh mục vào danh sách
                  });
                  Navigator.pop(context);  // Đóng dialog
                } else {
                  // Nếu không có tên danh mục, có thể hiển thị thông báo lỗi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập tên danh mục')),
                  );
                }
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _putItem(BuildContext context, String type,name) async {
    // Dữ liệu gửi lên API
    var token = await Auth.getAccessToken();

    // Gọi API thêm hoặc cập nhật sản phẩm
    const url = 'http://10.0.2.2:1000/api/admin/food';
    try {
      final response = type == 'add' ?
      await http.post(Uri.parse(url), headers: {HttpHeaders.authorizationHeader: "Bearer $token"}, body: {
        'name': nameController.text,
        'categoryId': categoryId,
        'unitId': unitId,
        'imageUrl': imageController.text.isNotEmpty ? imageController.text : '',
      }):
      await http.put(Uri.parse(url), headers: {HttpHeaders.authorizationHeader: "Bearer $token"}, body: {
        'name': name,
        'categoryId': categoryId,
        'unitId': unitId,
        'imageUrl': imageController.text.isNotEmpty ? imageController.text : '',
      });
      Navigator.pop(context);
      if(type != 'add'){
        Navigator.pop(context);
      }
      if (response.statusCode == 201 || response.statusCode == 200 ) {
        // Xử lý khi thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sản phẩm đã ${type == 'add' ? 'thêm' : 'cập nhật'} thành công kéo để cập nhật giao diện')),
        );
      } else {
        // Xử lý khi có lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Có lỗi xảy ra')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể kết nối với máy chủ')),
      );
    }
  }
  bool _validateFields(type) {
    if (type =='add'){
      if (nameController.text.isEmpty || categoryId == null || unitId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tên sản phẩm, danh mục và đơn vị là bắt buộc')),
        );return false;
      }
      return true;
    }else if ( categoryId == null || unitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Danh mục và đơn vị là bắt buộc')),
      );return false;
    }
    return true;
  }
  Future<void> _fetchUnits() async {
    var token = await Auth.getAccessToken();
    final response =  await http.get(Uri.parse('http://10.0.2.2:1000/api/admin/unit'),
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
    if (response.statusCode == 200) {
      setState(() {
        units = json.decode(response.body);
      });
    }
  }

}
