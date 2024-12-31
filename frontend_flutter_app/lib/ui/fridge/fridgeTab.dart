import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_flutter_app/ui/fridge/utils.dart';
import 'package:frontend_flutter_app/ui/fridge/productDetail.dart';


class FridgeTab extends StatefulWidget {
  const FridgeTab({super.key});

  @override
  State<FridgeTab> createState() => _FridgeTabState();
}

class _FridgeTabState extends State<FridgeTab> with TickerProviderStateMixin {
  late final TabController tabController;
  int initialIndex = 1;
  List<Map<String, dynamic>> foodList = [];
  List<Map<String, dynamic>> usedList = [];
  List<Map<String, dynamic>> expiredList = [];

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

      final response = await http.get(
          Uri.parse('http://10.0.2.2:1000/api/fridge'),
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"}
      );

      if (response.statusCode == 228) {
        final jsonData = json.decode(response.body); // Trả về dạng Map<String, dynamic>

        // Chuyển đổi dữ liệu từ JSON
        final List<dynamic> items = jsonData['items'];

        // Cập nhật danh sách
        setState(() {
          foodList = items
            .where((item) => item['quantity'] > 0)
            .map((item) {
            return {
              'id': item['_id'],
              'name': item['food']['name'].toString()
            };
          }).toList();

          usedList = items
            .where((item) => item['isUsed'] == true)
            .map((item) {
              return {
                'id': item['_id'],
                'name': item['food']['name'].toString(),
                'usedAt': item['usedAt'].toString(),
                'usedQuantity': item['usedQuantity'].toString()
              };
          }).toList();

          expiredList = items
              .where((item) => DateTime.parse(item['expirationDate']).isBefore(DateTime.now()))
              .map((item) {
                return {
                  'id': item['_id'],
                  'name': item['food']['name'].toString(),
                  'expirationDate': item['expirationDate'].toString(),
                };
              }).toList();
        });

        print(expiredList);
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
        Tab(text: 'Trong tủ lạnh',),
        Tab(text: 'Đã sử dụng',),
        Tab(text: 'Quá hạn',),
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
                  usedTab(),
                  expiredTab(),
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
                      Navigator.pushNamed(context, "/fridge/add-product");
                    },
                    child: const Icon(Icons.add)),
              ],
            ),
          ),
          ...foodList.map((e) => fridgeItem(e['name'], e['id'])),
        ],
      ),
    );
  }

  Widget usedTab() {
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
          ...usedList.map((e) => usedItem(e['name'], e['usedAt'], e['usedQuantity'])),
        ],
      ),
    );
  }

  Widget expiredTab() {
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
          ...expiredList.map((e) => expiredItem(e['name'], e['expirationDate'])),
        ],
      ),
    );
  }

  Widget usedItem(String name, String usedAt, String usedQuantity) {
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
                      "Ngày sử dụng: ${formatDate(usedAt)}",
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

  Widget expiredItem(String name, String expirationDate) {
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
                      "Ngày quá hạn: ${formatDate(expirationDate)}",
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

  Widget fridgeItem(String name, String itemId) {
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
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetail(id: 'Hello from First Screen!')));
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
                  onPressed: () {
                    showUsedQuantity(context, name, (quantity) {
                      markAsUsed(itemId, quantity);
                    });
                  },
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

  void showDeleteConfirmationDialog(BuildContext context, String itemName, Function onConfirm) {
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

  void showUsedQuantity(BuildContext context, String itemId, Function(String) onConfirm) {
    final TextEditingController quantityController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String quantity = '';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text(
              'Đánh dấu thực phẩm đã sử dụng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số lượng?',
                      border: OutlineInputBorder(),
                      errorStyle: TextStyle(color: Colors.red), // Định dạng lỗi
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số lượng';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    onConfirm(quantityController.text);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Xác nhận'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Hủy bỏ'),
              ),
            ],
          );
        }
        );
  }

  void markAsUsed(String itemId, String quantity) async {
    try {
      final accessToken = await Auth.getAccessToken();

      final response = await http.put(
          Uri.parse('http://10.0.2.2:1000/api/fridge/used/$itemId'),
          headers: <String, String>{
            "Content-type": "application/json; charset=UTF-8",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          },
          body: jsonEncode(<String, String>{"usedQuantity": quantity})
      );

      if (response.statusCode == 200) {
        print("success");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu thành công')),
        );
      } else {
        print(response.statusCode);
        throw Exception('Failed to load data: ${response.body}');
      }

    } catch (error) {
      print('Error fetching data: $error');
    }
  }

}


