import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/constant.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/helper/hotmessage.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

part 'admin.category-management.dart';
part 'admin.unit-management.dart';
part 'admin.user-management.dart';
part 'admin.usergroup-management.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _index = 0;
  String _title = 'Quản lý người dùng';
  var pages = [
    UserManagementPage(),
    CategoryManagementPage(),
    UnitManagementPage()
  ];

  void _updatePage(int index, String title) {
    setState(() {
      _index = index;
      _title = title;
    });
  }

  @override
  void initState() {
    super.initState();
    _updatePage(0, 'Quản lý người dùng');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: _title,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Quản lý người dùng'),
              onTap: () {
                _updatePage(0, 'Quản lý người dùng');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Quản lý danh mục'),
              onTap: () {
                _updatePage(1, 'Quản lý danh mục');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Quản lý đơn vị'),
              onTap: () {
                _updatePage(2, 'Quản lý đơn vị');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[_index],
    );
  }
}
