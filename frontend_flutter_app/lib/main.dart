import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/pages/fridge.dart';
import 'package:frontend_flutter_app/pages/login.dart';
import 'package:frontend_flutter_app/pages/meals-plan.dart';
import 'package:frontend_flutter_app/pages/recipe.dart';
import 'package:frontend_flutter_app/pages/report.dart';
import 'package:frontend_flutter_app/pages/search.dart';
import 'package:frontend_flutter_app/pages/shopping-list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final bool isLoggedIn = await Auth.authenticate();
  bool isLoggedIn = true;
  final MyApp myApp = MyApp(
    initialRoute: isLoggedIn ? "/" : "/login",
  );
  runApp(myApp);
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
        "/": (context) => MyHomePage(title: "Ứng dụng đi chợ tiện lợi"),
        "/login": (context) => LoginPage(),
        "/shopping-list": (context) => ShoppingListPage(),
        "/meals-plan": (context) => MealsPlanPage(),
        "/fridge": (context) => FridgePage(),
        "/recipe": (context) => RecipePage(),
        "/search": (context) => SearchPage(),
        "/report": (context) => ReportPage()
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

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            const Expanded(
              child: Image(image: AssetImage("assets/icon-image-ud-di-cho-tien-loi-removebg-preview.png")),
              flex: 2,
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
                            onTap: () => {
                              Navigator.pushNamed(context, "/shopping-list")
                            },
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
                            onTap: () => {
                              Navigator.pushNamed(context, "/meals-plan")
                            },
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
                            onTap: () => {
                              Navigator.pushNamed(context, "/fridge")
                            },
                          ),
                          GestureDetector(
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage("assets/recipe.png"),
                                  width: 50,
                                  height: 50,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Công thức nấu ăn",
                                    style: TextStyle(fontSize: 16),
                                  )
                                )
                                
                              ],
                            ),
                            onTap: () => {
                              Navigator.pushNamed(context, "/recipe")
                            },
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
                                  )
                                )
                                
                              ],
                            ),
                            onTap: () => {
                              Navigator.pushNamed(context, "/search")
                            },
                          ),
                          GestureDetector(
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage("assets/pie-chart.png"),
                                  width: 50,
                                  height: 50,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Thống kê, báo cáo",
                                    style: TextStyle(fontSize: 16),
                                  )
                                )
                                
                              ],
                            ),
                            onTap: () => {
                              Navigator.pushNamed(context, "/report")
                            },
                          )
                        ],
                      ),
                    )
                    
                  ],
                ),
              ),
            )
          ]
        ),
      ),
    );
  }
}
