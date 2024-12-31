import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductDetail extends StatefulWidget {
  final String id;

  const ProductDetail({Key? key, required this.id}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {

  Future<void> fetchData(id) async {
    try {
      final accessToken = await Auth.getAccessToken();

      final response = await http.get(
          Uri.parse('http://10.0.2.2:1000/api/fridge/${id}'),
          headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"}
      );

      if (response.statusCode == 228) {
        final jsonData = json.decode(response.body); // Trả về dạng Map<String, dynamic>

        // Chuyển đổi dữ liệu từ JSON
        final List<dynamic> items = jsonData['items'];

        print(items);

        // Cập nhật danh sách
        setState(() {

        });

      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Quản lý thực phẩm"),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        color: Colors.white,
        child: Column(
          children: [
            item(
                "Tên thực phẩm",
                "assets/fridge-img/food-icon.png",
                "Tên thực phẩm"
            ),
            const SizedBox(
              height: 10,
            ),
            item(
                "Số lượng",
                "assets/fridge-img/quantity.png",
                "số lượng"
            ),
            const SizedBox(
              height: 10,
            ),
            item(
                "Vị trí trong tủ lạnh",
                "assets/fridge.png",
                "vị trí"),
            const SizedBox(
              height: 10,
            ),
            item(
                "Ngày hết hạn",
                "assets/fridge-img/expired.png",
                "Ngày hết hạn"),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget item(String label, String image, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image(
                image: AssetImage(image),
                width: 40,
                height: 40,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )
              )
            ],
          ),
          SizedBox(height: 8), // Khoảng cách giữa Row và Value
          TextField(
            decoration: InputDecoration(
              enabled: false,
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 20, // Kích thước chữ
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
              fillColor: Colors.grey,
              filled: true,
              border: OutlineInputBorder(), // Hoặc khác như: OutlineInputBorder(), InputBorder.none, hoặc InputDecoration.none
            ),
          )
        ],
        )

    );
  }
}
