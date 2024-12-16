import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/data/auth.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.title});

  final String title;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

enum UserAccountOptions { changeInfo, changePassword, logOut }

class _MyAppBarState extends State<MyAppBar> {
  UserAccountOptions? selectedOption;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      title: Text(widget.title),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: <Widget>[
        PopupMenuButton<UserAccountOptions>(
          icon: Icon(Icons.account_circle),
          onSelected: (option) => {
            setState(() {
              selectedOption = option;
            })
          },
          itemBuilder: (context) => <PopupMenuEntry<UserAccountOptions>>[
            PopupMenuItem(
              value: UserAccountOptions.changeInfo,
              child: Text("Thay đổi thông tin tài khoản"),
              onTap: () {
                Navigator.pushNamed(context, "/user/change-info");
              },
            ),
            PopupMenuItem(
              value: UserAccountOptions.changePassword,
              child: Text("Đổi mật khẩu"),
              onTap: () {
                Navigator.pushNamed(context, "/user/change-password");
              },
            ),
            PopupMenuItem(
              value: UserAccountOptions.logOut,
              child: Text("Đăng xuất"),
              onTap: () async {
                await Auth.deleteAccessTokenOnDisk();
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (Route<dynamic> route) => false);
              },
            ),
          ],
        )
      ],
    );
  }
}
