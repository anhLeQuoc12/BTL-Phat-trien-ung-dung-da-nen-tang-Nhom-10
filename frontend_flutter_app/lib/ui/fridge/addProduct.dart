import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Thêm thực phẩm"),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        color: Colors.white,
        child: Column(
          children: [
            item(
                "Tên thực phẩm",
                "Tên thực phẩm",
                "Tên thức phẩm không được bỏ trống",
                "assets/fridge-img/food-icon.png",
                TextEditingController()),
            const SizedBox(
              height: 10,
            ),
            item(" Số lượng", " Số lượng", " Số lượng không được bỏ trống",
                "assets/fridge-img/quantity.png", TextEditingController()),
            const SizedBox(
              height: 10,
            ),
            item(
                " Vị trí trong tủ lạnh",
                " Vị trí trong tủ lạnh",
                " Vị trí trong tủ lạnh không được bỏ trống",
                "assets/fridge.png",
                TextEditingController()),
            const SizedBox(
              height: 10,
            ),
            item(
                " Ngày hết hạn",
                " Ngày hết hạn",
                " Ngày hết hạn không được bỏ trống",
                "assets/fridge-img/expired.png",
                TextEditingController()),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text("Thêm thực phẩm",
                      style: TextStyle(color: Colors.white))),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text("Hủy bỏ", style: TextStyle(color: Colors.white)),
              )
            ])
          ],
        ),
      ),
    );
  }

  Widget item(String label, String hintText, String validate, String image,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 4),
      child: Row(
        children: [
          Image(
            image: AssetImage(image),
            width: 40,
            height: 40,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                  hintText: hintText,
                  labelText: label,
                  fillColor: Colors.grey,
                  filled: true,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      controller.clear();
                    },
                    child: Icon(
                      Icons.clear_outlined,
                    ),
                  )),
              controller: controller,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return validate;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
