import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/models/recipe.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:frontend_flutter_app/ui/drawer.dart';
import 'package:frontend_flutter_app/ui/fridge/fridge.dart';
import 'package:frontend_flutter_app/ui/login/login.dart';
import 'package:frontend_flutter_app/ui/meals-plan/meals-plan.dart';
import 'package:frontend_flutter_app/ui/recipe/recipes-list.dart';
import 'package:frontend_flutter_app/ui/report/report.dart';
import 'package:frontend_flutter_app/ui/search/search.dart';
import 'package:frontend_flutter_app/ui/shopping-list/shopping-list.dart';
import 'package:frontend_flutter_app/ui/user/change-info/change-info.dart';
import 'package:frontend_flutter_app/ui/user/change-password/change-password.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authResult = await Auth.authenticate();
  late String initialRoute;
  if (authResult == "Not authenticated") {
    initialRoute = "/login";
  } else {
    if (authResult["role"] == "admin") {
      initialRoute = "/admin";
    } else {
      initialRoute = "/home";
    }
  }
  final MyApp myApp = MyApp(
    initialRoute: initialRoute,
  );
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (context) => RecipeModel())],
    child: myApp,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng đi chợ tiện lợi - Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        "/home": (context) => MyHomePage(title: "Ứng dụng đi chợ tiện lợi"),
        "/admin": (context) => AdminPage()
        "/login": (context) => LoginScreen(),
        "/shopping-list": (context) => ShoppingListScreen(),
        "/meals-plan": (context) => MealsPlanScreen(),
        "/fridge": (context) => FridgeScreen(),
        "/recipe": (context) => const RecipesListScreen(),
        "/search": (context) => SearchScreen(),
        "/report": (context) => ReportScreen(),
        "/user/change-info": (context) => ChangeInfoScreen(),
        "/user/change-password": (context) => ChangePasswordScreen()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum UserAccountOptions { changeInfo, changePassword, logOut }

class _MyHomePageState extends State<MyHomePage> {
  UserAccountOptions? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.title),
      drawer: const MyAppDrawer(),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Expanded(
            flex: 2,
            child: Image(
                image: AssetImage("assets/icon-image-ud-di-cho-tien-loi.png")),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/grocery-cart.png"),
                                width: 50,
                                height: 50,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "Danh sách mua sắm",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          onTap: () =>
                              {Navigator.pushNamed(context, "/shopping-list")},
                        ),
                        GestureDetector(
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/fried-rice.png"),
                                width: 50,
                                height: 50,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "Dự định bữa ăn",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          onTap: () =>
                              {Navigator.pushNamed(context, "/meals-plan")},
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/fridge.png"),
                                width: 50,
                                height: 50,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "Quản lý thực phẩm tủ lạnh",
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          onTap: () =>
                              {Navigator.pushNamed(context, "/fridge")},
                        ),
                        GestureDetector(
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/recipe/recipe.png"),
                                width: 50,
                                height: 50,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Công thức nấu ăn",
                                    style: TextStyle(fontSize: 16),
                                  ))
                            ],
                          ),
                          onTap: () =>
                              {Navigator.pushNamed(context, "/recipe")},
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/search.png"),
                                width: 50,
                                height: 50,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Tìm kiếm thực phẩm",
                                    style: TextStyle(fontSize: 16),
                                  ))
                            ],
                          ),
                          onTap: () =>
                              {Navigator.pushNamed(context, "/search")},
                        ),
                        GestureDetector(
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image:
                                    AssetImage("assets/report/pie-chart.png"),
                                width: 50,
                                height: 50,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Thống kê, báo cáo",
                                    style: TextStyle(fontSize: 16),
                                  ))
                            ],
                          ),
                          onTap: () =>
                              {Navigator.pushNamed(context, "/report")},
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
