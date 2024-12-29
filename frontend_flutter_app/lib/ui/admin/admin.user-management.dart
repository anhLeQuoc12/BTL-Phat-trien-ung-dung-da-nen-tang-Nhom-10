part of 'admin.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<User>> _users;

  @override
  void initState() {
    super.initState();
    _users = fetchUsers();
  }

  Future<List<User>> fetchUsers() async {
    try {
      var token = await Auth.getAccessToken();
      final response = await http.post(
        Uri.http(AppConstant.baseUrl, '/api/admin/user-management/query'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          'page': 1, // Adjust the body based on the API documentation
          'limit': 10,
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print(data);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load users. Status code: ${response.statusCode}');
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
      body: Column(
        children: [
          Container(
            color: Colors.purple.shade50,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm người dùng',
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
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No users found'));
                } else {
                  List<User> users = snapshot.data!;

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Text(
                            users[index]
                                .name[0], // Display first letter of name
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(users[index].name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditUserPage(user: users[index])),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserDetailPage(user: users[index])),
                                );
                              },
                            ),
                          ],
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

class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String? groupId;

  User(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email,
      required this.role,
      required this.groupId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      groupId: json['groupId'],
    );
  }
}

class EditUserPage extends StatefulWidget {
  final User user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController groupCodeController = TextEditingController();

  // Initialize with dummy data for now
  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.name;
    emailController.text = widget.user.email;
    phoneController.text = widget.user.phone;
    groupCodeController.text = widget.user.groupId ?? '';
  }

  Future<void> updateUser() async {
    if (nameController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên người dùng không được để trống');
      return;
    }
    if (emailController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên người dùng không được để trống');
      return;
    }
    if (phoneController.text.trim().isEmpty) {
      HotMessage.showToast('Lỗi', 'Tên người dùng không được để trống');
      return;
    }
    try {
      var token = await Auth.getAccessToken();
      var updateBody = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'groupId': groupCodeController.text,
      };
      final response = await http.patch(
        Uri.http(AppConstant.baseUrl, '/api/admin/user/${widget.user.id}'),
        headers: <String, String>{
          "Content-type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token"
        },
        body: json.encode({'updateBody': updateBody}),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Lỗi');
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
        title: Text('Sửa thông tin người dùng'),
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
                  labelText: 'Tên',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => nameController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => emailController.clear(),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => phoneController.clear(),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),

              // Group Code Field
              TextFormField(
                controller: groupCodeController,
                decoration: InputDecoration(
                  labelText: 'Mã nhóm',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => groupCodeController.clear(),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: updateUser,
                style: ElevatedButton.styleFrom(
                  textStyle:
                      TextStyle(fontSize: 16), // Optional: customize text style
                  backgroundColor: Colors.purple, // Background color
                  foregroundColor: Colors.white, // Text color
                ),
                child: Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final User user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết người dùng'),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Handle profile icon action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.purple.shade100,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 16),

            // User Name
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // User Information Section
            _buildSectionTitle('Thông tin người dùng:'),
            _buildDetailItem('Email', user.email),
            _buildDetailItem('Số điện thoại', user.phone),
            SizedBox(height: 24),

            // User Group Section
            _buildSectionTitle('Thông tin nhóm người dùng:'),
            _buildDetailItem(
              '',
              user.groupId == null
                  ? 'Không tìm thấy thông tin nhóm người dùng'
                  : '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.isEmpty ? value : '$label: $value',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
