import 'package:flutter/material.dart';

class MyAppDrawer extends StatelessWidget {
  const MyAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 25,
          ),
          ListTile(
            leading: Image(
              image: AssetImage("assets/home.png"),
              width: 40,
              height: 40,
            ),
            title: Text("Màn hình chính"),
            onTap: () => {Navigator.pushNamed(context, "/home")},
          ),
          ListTile(
            leading: Image(
              image: AssetImage("assets/grocery-cart.png"),
              width: 40,
              height: 40,
            ),
            title: Text("Danh sách mua sắm"),
            onTap: () => {Navigator.pushNamed(context, "/shopping-list")},
          ),
          ListTile(
            leading: Image(
              image: AssetImage("assets/fried-rice.png"),
              width: 40,
              height: 40,
            ),
            title: Text("Dự định bữa ăn"),
            onTap: () => {Navigator.pushNamed(context, "/meals-plan")},
          ),
          ListTile(
            leading: Image(
              image: AssetImage("assets/fridge.png"),
              width: 40,
              height: 40,
            ),
            title: Text("Quản lý tủ lạnh"),
            onTap: () => {Navigator.pushNamed(context, "/fridge")},
          ),
          ListTile(
            leading: Image(
              image: AssetImage("assets/recipe.png"),
              width: 40,
              height: 40,
            ),
            title: Text("Công thức nấu ăn"),
            onTap: () => {Navigator.pushNamed(context, "/recipe")},
          ),
          ListTile(
            leading: Image(
              image: AssetImage("assets/search.png"),
              width: 40,
              height: 40,
            ),
            title: Text("Tìm kiếm thực phẩm"),
            onTap: () => {Navigator.pushNamed(context, "/search")},
          ),
          ListTile(
            leading: Image(
              image: AssetImage("assets/pie-chart.png"),
              width: 40,
              height: 40,
            ),
            title: Text("Thống kê, báo cáo"),
            onTap: () => {Navigator.pushNamed(context, "/report")},
          ),
        ],
      ),
    );
  }
}
