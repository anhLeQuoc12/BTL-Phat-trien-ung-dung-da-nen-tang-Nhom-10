part of 'admin.dart';

class UserGroupManagementPage extends StatefulWidget {
  const UserGroupManagementPage({super.key});

  @override
  State<UserGroupManagementPage> createState() => _UserGroupManagementPageState();
}

class _UserGroupManagementPageState extends State<UserGroupManagementPage> {
  late Future<List<UserGroup>> _usergroups;
  List<UserGroup> _allUserGroups = [];
  List<UserGroup> _filteredUserGroups = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // Timer for debounce

  @override
  void initState() {
    super.initState();
    _usergroups = fetchUserGroups();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<UserGroup>> fetchUserGroups() async {
    try {
      var token = await Auth.getAccessToken();
      final response = await http.get(
        Uri.http(AppConstant.baseUrl, '/api/admin/group'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<UserGroup> usergroups = data.map((json) => UserGroup.fromJson(json)).toList();
        setState(() {
          _allUserGroups = usergroups;
          _filteredUserGroups = usergroups;
        });
        return usergroups;
      } else {
        throw Exception(
            'Failed to load usergroups. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterUserGroups(); // Trigger filtering after debounce duration
    });
  }

  void _filterUserGroups() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUserGroups = _allUserGroups
          .where(
              (usergroup) => usergroup.name.toLowerCase().contains(query)) // Filter logic
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
                hintText: 'Tìm nhóm người dùng',
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

          // UserGroups List
          Expanded(
            child: FutureBuilder<List<UserGroup>>(
              future: _usergroups,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (_filteredUserGroups.isEmpty) {
                  return Center(child: Text('Không tìm thấy nhóm người dùng'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredUserGroups.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            _filteredUserGroups[index]
                                .name[0], // Display first letter of name
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(_filteredUserGroups[index].name),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditUserGroupPage(
                                  usergroup: _filteredUserGroups[index],
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

class UserGroup {
  final String id;
  final String name;
  UserGroup({required this.id, required this.name});

  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      id: json['id'],
      name: json['name'],
    );
  }
}

class EditUserGroupPage extends StatefulWidget {
  final UserGroup usergroup;

  const EditUserGroupPage({super.key, required this.usergroup});

  @override
  State<EditUserGroupPage> createState() => _EditUserGroupPageState();
}

class _EditUserGroupPageState extends State<EditUserGroupPage> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();

  // Initialize with dummy data for now
  @override
  void initState() {
    super.initState();
    nameController.text = widget.usergroup.name;
  }

  Future<void> updateUserGroup() async {
    if (nameController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên nhóm người dùng không được để trống');
    }
    try {
      var token = await Auth.getAccessToken();
      var updateBody = {
        'name': nameController.text,
      };
      final response = await http.patch(
        Uri.http(AppConstant.baseUrl, '/api/admin/group/${widget.usergroup.id}'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode({'updateBody': updateBody}),
      );

      if (response.statusCode == 200) {
        HotMessage.showToast('Thành công', 'Cập nhật nhóm người dùng thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Cập nhật nhóm người dùng thành công');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Client error: ${e.message}');
      } else {
        throw Exception('An error occurred: $e');
      }
    }
  }

  Future<void> deleteUserGroup() async {
    try {
      var token = await Auth.getAccessToken();
      final response = await http.delete(
        Uri.http(AppConstant.baseUrl, '/api/admin/group/${widget.usergroup.id}'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        HotMessage.showToast('Thành công', 'Xoá nhóm người dùng thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Xoá nhóm người dùng thành công');
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
      appBar: AppBar(
        title: Text('Sửa thông tin nhóm người dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên nhóm người dùng',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: updateUserGroup,
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
                            Text('Bạn có chắc chắn muốn xoá nhóm người dùng này không?'),
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
                    await deleteUserGroup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: 16),
                  backgroundColor: Colors.red, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Xoá nhóm người dùng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateUserGroupPage extends StatefulWidget {
  const CreateUserGroupPage({super.key});

  @override
  State<CreateUserGroupPage> createState() => _CreateUserGroupPageState();
}

class _CreateUserGroupPageState extends State<CreateUserGroupPage> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> createUserGroup() async {
    if (nameController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên nhóm người dùng không được để trống');
    }
    try {
      var token = await Auth.getAccessToken();
      var createBody = {
        'name': nameController.text,
      };
      final response = await http.post(
        Uri.http(AppConstant.baseUrl, '/api/admin/group'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode(createBody),
      );

      if (response.statusCode == 201) {
        HotMessage.showToast('Thành công', 'Tạo nhóm người dùng thành công');
        Navigator.pop(context);
      } else {
        HotMessage.showToast('Lỗi', 'Xảy ra lỗi khi tạo nhóm người dùng');
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
      appBar: AppBar(
        title: Text('Tạo nhóm người dùng mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên nhóm người dùng',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: createUserGroup,
                style: ElevatedButton.styleFrom(
                  textStyle:
                      TextStyle(fontSize: 16), // Optional: customize text style
                  backgroundColor: Colors.purple, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Tạo nhóm người dùng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
