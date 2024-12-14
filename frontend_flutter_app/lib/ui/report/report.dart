import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Thống kê, báo cáo"),
      ),
      body: Center(
        child: Text("Trang Thống kê, báo cáo"),
      ),
    );
  }
}
