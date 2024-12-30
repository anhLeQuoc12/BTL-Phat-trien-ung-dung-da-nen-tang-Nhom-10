import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/ui/fridge/addProduct.dart';
import 'package:frontend_flutter_app/ui/fridge/productDetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FridgeTab extends StatefulWidget {
  const FridgeTab({super.key});

  @override
  State<FridgeTab> createState() => _FridgeTabState();
}

class _FridgeTabState extends State<FridgeTab> with TickerProviderStateMixin {
  late final TabController tabController;
  int initialIndex = 1;
  List<String> foodList = [];
  @override
  void initState() {
    super.initState();
    fetchData(); // Gọi API khi màn hình được khởi tạo

    tabController =
        TabController(length: 3, vsync: this, initialIndex: initialIndex - 1);
  }

  Future<void> fetchData() async {
    try {
      final accessToken = await Auth.getAccessToken();
      // Thay thế URL bằng API của bạn
      final response = await http.get(
          Uri.parse('http://10.0.2.2:1000/api/fridge'),
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});

      print("response body: " + response.body);

      if (response.statusCode == 228) {
        final jsonData =
            json.decode(response.body); // Trả về dạng Map<String, dynamic>

        // Chuyển đổi dữ liệu từ JSON
        final List<dynamic> items = jsonData['items'];

        // Cập nhật danh sách
        setState(() {
          foodList =
              items.map((item) => item['food']['name'].toString()).toList();
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: tabController,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(
          text: 'Trong tủ lạnh',
        ),
        Tab(
          text: 'Đã sử dụng',
        ),
        Tab(
          text: 'Quá hạn',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.grey),
                    )),
                child: _buildTabBar(),
              ),
              Expanded(
                child: TabBarView(controller: tabController, children: [
                  fridgeTab(),
                  fridgeTab2(),
                  fridgeTab3(),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget fridgeTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(children: [
                  Image(
                    image: AssetImage("assets/fridge-img/in-fridge.png"),
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Danh sách thực phẩm trong tủ lạnh:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
                GestureDetector(
                    onTap: () {
                      // Navigator.pushNamed(context, "/fridge/add-product");
                      Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddProduct()));
                    },
                    child: const Icon(Icons.add)),
              ],
            ),
          ),
          ...foodList.map((e) => item1(e)),
        ],
      ),
    );
  }

  Widget fridgeTab2() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Image(
                    image: AssetImage("assets/fridge-img/used.png"),
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Danh sách thực phẩm đã sử dụng:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
              ],
            ),
          ),
          ...foodList.map((e) => item2(e)),
        ],
      ),
    );
  }

  Widget fridgeTab3() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Image(
                    image: AssetImage("assets/fridge-img/expired.png"),
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Danh sách thực phẩm đã quá hạn:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ]),
              ],
            ),
          ),
          ...foodList.map((e) => item3(e)),
        ],
      ),
    );
  }

  Widget item2(String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const Image(
                    image: AssetImage("assets/grocery-cart.png"),
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Ngày sử dụng: 10/10/2022",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ]),
              Row(
                children: [
                  const Icon(Icons.delete),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget item3(String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const Image(
                    image: AssetImage("assets/grocery-cart.png"),
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Ngày quá hạn: 10/10/2022",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ]),
              Row(
                children: [
                  const Icon(Icons.delete),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget item1(String name) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          // Navigator.pushNamed(context, "/fridge/product-detail");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProductDetail()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: const Image(
                  image: AssetImage("assets/grocery-cart.png"),
                  width: 40,
                  height: 40,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ]),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.deepPurple),
                  ),
                  child: const Text("Đã sử dụng",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Icon(Icons.edit),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showDeleteConfirmationDialog(context, name, () {
                      print('$name đã bị xóa!');
                    });
                  },
                  child: const Icon(Icons.delete),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(
      BuildContext context, String itemName, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Xóa thực phẩm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa thực phẩm "$itemName"?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('Có'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Không'),
            ),
          ],
        );
      },
    );
  }
}
