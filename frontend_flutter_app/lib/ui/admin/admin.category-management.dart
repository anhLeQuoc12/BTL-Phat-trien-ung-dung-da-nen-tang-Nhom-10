part of 'admin.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  late Future<List<Category>> _categories;
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // Timer for debounce

  @override
  void initState() {
    super.initState();
    _categories = fetchCategories();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<Category>> fetchCategories() async {
    try {
      var token = await Auth.getAccessToken();
      final response = await http.get(
        Uri.http(AppConstant.baseUrl, '/api/admin/category'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Category> categories =
            data.map((json) => Category.fromJson(json)).toList();
        setState(() {
          _allCategories = categories;
          _filteredCategories = categories;
        });
        return categories;
      } else {
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterCategories(); // Trigger filtering after debounce duration
    });
  }

  void _filterCategories() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories
          .where((category) =>
              category.name.toLowerCase().contains(query)) // Filter logic
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel(); // Cancel debounce timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.purple.shade50,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm danh mục',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateCategoryPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(fontSize: 16),
                    backgroundColor: Colors.red, // Background color
                    foregroundColor: Colors.white, // Text color
                  ),
                  icon: Icon(Icons.add, size: 20), // Add your desired icon here
                  label: Text('Thêm danh mục'), // Text for the button
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (_filteredCategories.isEmpty) {
                  return Center(child: Text('Không tìm thấy danh mục'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            _filteredCategories[index]
                                .name[0], // Display first letter of name
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(_filteredCategories[index].name),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCategoryPage(
                                  category: _filteredCategories[index],
                                ),
                              ),
                            );
                          },
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

class Category {
  final String id;
  final String name;
  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class EditCategoryPage extends StatefulWidget {
  final Category category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();

  // Initialize with dummy data for now
  @override
  void initState() {
    super.initState();
    nameController.text = widget.category.name;
  }

  Future<void> updateCategory() async {
    if (nameController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên danh mục không được để trống');
      return;
    }
    try {
      var token = await Auth.getAccessToken();
      var updateBody = {
        'name': nameController.text,
      };
      final response = await http.patch(
        Uri.http(
            AppConstant.baseUrl, '/api/admin/category/${widget.category.id}'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode(updateBody),
      );

      if (response.statusCode == 200) {
        HotMessage.showToast('Thành công', 'Cập nhật danh mục thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Cập nhật danh mục thành công');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Client error: ${e.message}');
      } else {
        throw Exception('An error occurred: $e');
      }
    }
  }

  Future<void> deleteCategory() async {
    try {
      var token = await Auth.getAccessToken();
      final response = await http.delete(
        Uri.http(
            AppConstant.baseUrl, '/api/admin/category/${widget.category.id}'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        HotMessage.showToast('Thành công', 'Xoá danh mục thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Xoá danh mục thành công');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Client error: ${e.message}');
      } else {
        throw Exception('An error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Sửa thông tin danh mục'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên danh mục',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: updateCategory,
                style: ElevatedButton.styleFrom(
                  textStyle:
                      TextStyle(fontSize: 16), // Optional: customize text style
                  backgroundColor: Colors.purple, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Lưu'),
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Xác nhận'),
                        content: Text(
                            'Bạn có chắc chắn muốn xoá danh mục này không?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // User canceled
                            },
                            child: Text('Huỷ'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // User confirmed
                            },
                            child: Text('Xác nhận'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    await deleteCategory();
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Colors.red, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Xoá danh mục'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateCategoryPage extends StatefulWidget {
  const CreateCategoryPage({super.key});

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> createCategory() async {
    if (nameController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên danh mục không được để trống');
      return;
    }
    try {
      var token = await Auth.getAccessToken();
      var createBody = {
        'name': nameController.text,
      };
      final response = await http.post(
        Uri.http(AppConstant.baseUrl, '/api/admin/category'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode(createBody),
      );

      if (response.statusCode == 201) {
        HotMessage.showToast('Thành công', 'Tạo danh mục thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Xảy ra lỗi khi tạo danh mục');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Client error: ${e.message}');
      } else {
        throw Exception('An error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Tạo danh mục mới'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên danh mục',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: createCategory,
                style: ElevatedButton.styleFrom(
                  textStyle:
                      TextStyle(fontSize: 16), // Optional: customize text style
                  backgroundColor: Colors.purple, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Tạo danh mục'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
