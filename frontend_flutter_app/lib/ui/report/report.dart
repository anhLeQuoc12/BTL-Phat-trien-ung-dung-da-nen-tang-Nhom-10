import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:frontend_flutter_app/ui/drawer.dart';
import 'package:http/http.dart' as http;

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future resFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final currentDate = DateTime.now();
    final mondayDate = mostRecentMonday(currentDate);
    final sundayDate = mostRecentSunday(currentDate);
    final startDate =
        "${mondayDate.year}-${mondayDate.month}-${mondayDate.day}";
    final endDate = "${sundayDate.year}-${sundayDate.month}-${sundayDate.day}";
    resFuture = getWeeklyShoppingReport(startDate, endDate);
  }

  DateTime mostRecentMonday(DateTime date) =>
      DateTime(date.year, date.month, date.day - (date.weekday - 1));

  DateTime mostRecentSunday(DateTime date) =>
      DateTime(date.year, date.month, date.day + (7 - date.weekday));

  Future<dynamic> getWeeklyShoppingReport(
      String startDate, String endDate) async {
    final accessToken = await Auth.getAccessToken();
    final resFuture = http.get(
        Uri.parse(
            "http://10.0.2.2:1000/api/weekly-report?startDate=$startDate&endDate=$endDate"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    final waitForOneSecondFuture =
        Future.delayed(const Duration(seconds: 1), () {
      return "ok";
    });
    final res = (await Future.wait([resFuture, waitForOneSecondFuture]))[0]
        as http.Response;
    if (res.statusCode == 200) {
      final report = jsonDecode(res.body);
      return report;
    } else {
      throw Exception(
          "Đã có lỗi xảy ra trong quá trình tải dữ liệu thống kê của bạn.");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(title: "Thống kê mức độ mua sắm"),
      drawer: const MyAppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/report/pie-chart.png"),
                    width: 40,
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Chọn tuần muốn thống kê",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.5),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
