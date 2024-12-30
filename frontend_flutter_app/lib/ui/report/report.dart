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
  late List<String> weeksList;
  late String chosenWeek;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weeksList = createWeeksList();
    chosenWeek = weeksList.last;
    final dateQuerySentToServer = getStartDateAndEndDate(chosenWeek);
    resFuture = getWeeklyShoppingReport(
        dateQuerySentToServer["startDate"], dateQuerySentToServer["endDate"]);

    print(weeksList);
    print(dateQuerySentToServer);
  }

  List<String> createWeeksList() {
    List<String> weeksList = [];
    final currentDate = DateTime.now();
    for (int i = 5; i > 0; i--) {
      final mondayDate = getMondayDateOfWeeksBefore(currentDate, i);
      final sundayDate = getSundayDateOfWeeksBefore(currentDate, i);
      final week =
          "${mondayDate.day}/${mondayDate.month}/${mondayDate.year} - ${sundayDate.day}/${sundayDate.month}/${sundayDate.year}";
      weeksList.add(week);
    }
    return weeksList;
  }

  DateTime getMondayDateOfWeeksBefore(DateTime date, int weeksBefore) =>
      DateTime(date.year, date.month,
          date.day - (date.weekday - 1) - 7 * weeksBefore);

  DateTime getSundayDateOfWeeksBefore(DateTime date, int weeksBefore) =>
      DateTime(date.year, date.month,
          date.day + (7 - date.weekday) - 7 * weeksBefore);

  dynamic getStartDateAndEndDate(String week) {
    final dates = week.split(" - ");
    final startDateList = dates[0].split("/");
    final startDate =
        "${startDateList[2]}-${startDateList[1]}-${startDateList[0]}";
    final endDateList = dates[1].split("/");
    final endDate = "${endDateList[2]}-${endDateList[1]}-${endDateList[0]}";
    return {"startDate": startDate, "endDate": endDate};
  }

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
      if (res.statusCode == 400) {
        throw Exception("Không có dữ liệu.");
      } else {
        throw Exception(
            "Đã có lỗi xảy ra trong quá trình tải dữ liệu thống kê của bạn.");
      }
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
            DropdownButton(
              value: chosenWeek,
              padding: EdgeInsets.all(8),
              // style: TextStyle(
              //   height:
              // ),
              elevation: 16,
              onChanged: (value) {
                setState(() {
                  chosenWeek = value!;
                  final dateQuerySentToServer = getStartDateAndEndDate(value);
                  resFuture = getWeeklyShoppingReport(
                      dateQuerySentToServer["startDate"],
                      dateQuerySentToServer["endDate"]);
                });
              },
              items: weeksList.map<DropdownMenuItem<String>>(
                (String week) {
                  return DropdownMenuItem<String>(
                    value: week,
                    child: Text(week),
                  );
                },
              ).toList(),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/report/vegetables.png"),
                    width: 40,
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Các thực phẩm đã mua",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.5),
                    ),
                  )
                ],
              ),
            ),
            FutureBuilder(
              future: resFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                      child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ));
                } else if (snapshot.hasData) {
                  final report = snapshot.data!;
                  final List purchasedFoods = report["purchasedFoods"];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(25, 0, 25, 20),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Thực phẩm",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Số lượng",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: 50,
                                child: Text(
                                  "% so với tuần\ntrước đó",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: purchasedFoods.length,
                          itemBuilder: (context, index) {
                            final purchasedItem = purchasedFoods[index];
                            final foodName = purchasedItem["foodId"]["name"];
                            final foodUnit =
                                purchasedItem["foodId"]["unitId"]["name"];
                            return Container(
                              padding: EdgeInsets.all(15),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(foodName),
                                  Text(
                                      "${purchasedItem["quantity"]} $foodUnit"),
                                  Text(purchasedItem["percentageWithLastWeek"])
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(height: 1,);
                          },
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("${snapshot.error.toString().substring(11)}"),
                    ),
                  );
                }

                return const Center(
                    child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ));
              },
            ),
            Container(
                      margin: EdgeInsets.only(bottom: 40),
                      child: Text(""),
                    )
          ],
        ),
      ),
    );
  }
}
