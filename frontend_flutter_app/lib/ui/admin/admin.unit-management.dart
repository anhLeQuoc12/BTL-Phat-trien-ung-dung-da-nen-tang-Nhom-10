part of 'admin.dart';

class UnitManagementPage extends StatefulWidget {
  const UnitManagementPage({super.key});

  @override
  State<UnitManagementPage> createState() => _UnitManagementPageState();
}

class _UnitManagementPageState extends State<UnitManagementPage> {
  late Future<List<Unit>> _units;
  List<Unit> _allUnits = [];
  List<Unit> _filteredUnits = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // Timer for debounce

  @override
  void initState() {
    super.initState();
    _units = fetchUnits();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<Unit>> fetchUnits() async {
    try {
      var token = await Auth.getAccessToken();
      final response = await http.get(
        Uri.http(AppConstant.baseUrl, '/api/admin/unit'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Unit> units = data.map((json) => Unit.fromJson(json)).toList();
        setState(() {
          _allUnits = units;
          _filteredUnits = units;
        });
        return units;
      } else {
        throw Exception(
            'Failed to load units. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterUnits(); // Trigger filtering after debounce duration
    });
  }

  void _filterUnits() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUnits = _allUnits
          .where(
              (unit) => unit.name.toLowerCase().contains(query)) // Filter logic
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
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm đơn vị',
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

          // Units List
          Expanded(
            child: FutureBuilder<List<Unit>>(
              future: _units,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (_filteredUnits.isEmpty) {
                  return Center(child: Text('Không tìm thấy đơn vị'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredUnits.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            _filteredUnits[index]
                                .name[0], // Display first letter of name
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(_filteredUnits[index].name),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditUnitPage(
                                  unit: _filteredUnits[index],
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

class Unit {
  final String id;
  final String name;
  Unit({required this.id, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      name: json['name'],
    );
  }
}

class EditUnitPage extends StatefulWidget {
  final Unit unit;

  const EditUnitPage({super.key, required this.unit});

  @override
  State<EditUnitPage> createState() => _EditUnitPageState();
}

class _EditUnitPageState extends State<EditUnitPage> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();

  // Initialize with dummy data for now
  @override
  void initState() {
    super.initState();
    nameController.text = widget.unit.name;
  }

  Future<void> updateUnit() async {
    if (nameController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên đơn vị không được để trống');
      return;
    }
    try {
      var token = await Auth.getAccessToken();
      var updateBody = {
        'name': nameController.text,
      };
      final response = await http.patch(
        Uri.http(AppConstant.baseUrl, '/api/admin/unit/${widget.unit.id}'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode({'updateBody': updateBody}),
      );

      if (response.statusCode == 200) {
        HotMessage.showToast('Thành công', 'Cập nhật đơn vị thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Cập nhật đơn vị thành công');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Client error: ${e.message}');
      } else {
        throw Exception('An error occurred: $e');
      }
    }
  }

  Future<void> deleteUnit() async {
    try {
      var token = await Auth.getAccessToken();
      final response = await http.delete(
        Uri.http(AppConstant.baseUrl, '/api/admin/unit/${widget.unit.id}'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        HotMessage.showToast('Thành công', 'Xoá đơn vị thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Xoá đơn vị thành công');
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
      appBar: const MyAppBar(
        title: 'Sửa thông tin danh mục',
      ),
      appBar: MyAppBar(title: 'Sửa thông tin đơn vị'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên đơn vị',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: updateUnit,
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
                        content:
                            Text('Bạn có chắc chắn muốn xoá đơn vị này không?'),
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
                    await deleteUnit();
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Colors.red, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Xoá đơn vị'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateUnitPage extends StatefulWidget {
  const CreateUnitPage({super.key});

  @override
  State<CreateUnitPage> createState() => _CreateUnitPageState();
}

class _CreateUnitPageState extends State<CreateUnitPage> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> createUnit() async {
    if (nameController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên đơn vị không được để trống');
      return;
    }
    try {
      var token = await Auth.getAccessToken();
      var createBody = {
        'name': nameController.text,
      };
      final response = await http.post(
        Uri.http(AppConstant.baseUrl, '/api/admin/unit'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode(createBody),
      );

      if (response.statusCode == 201) {
        HotMessage.showToast('Thành công', 'Tạo đơn vị thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Xảy ra lỗi khi tạo đơn vị');
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
      appBar: MyAppBar(title: 'Tạo đơn vị mới'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên đơn vị',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: createUnit,
                style: ElevatedButton.styleFrom(
                  textStyle:
                      TextStyle(fontSize: 16), // Optional: customize text style
                  backgroundColor: Colors.purple, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Tạo đơn vị'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
