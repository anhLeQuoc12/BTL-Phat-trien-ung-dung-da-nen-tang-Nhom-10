import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/models/recipe.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import "package:http/http.dart" as http;
import 'package:provider/provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameTFController = TextEditingController();
  final contentTFController = TextEditingController();
  final descriptionTFController = TextEditingController();
  List<dynamic> _ingredients = [];
  List<TextEditingController> foodTFsControllers = [];
  List<TextEditingController> quantityTFsControllers = [];
  late final List foods;

  String? _nameTFError = null;

  // final emptyIngredient = {
  //   "food": {"id": "", "name": "", "unitName": ""},
  //   "quantity": ""
  // };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllFoods();
    _ingredients.add({
      "food": {"id": "", "name": "", "unitName": ""},
      "quantity": ""
    });
    _ingredients.add({
      "food": {"id": "", "name": "", "unitName": ""},
      "quantity": ""
    });
    foodTFsControllers.add(TextEditingController());
    quantityTFsControllers.add(TextEditingController());
    foodTFsControllers.add(TextEditingController());
    quantityTFsControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameTFController.dispose();
    foodTFsControllers.forEach((controller) {
      controller.dispose();
    });
    quantityTFsControllers.forEach((controller) {
      controller.dispose();
    });
    contentTFController.dispose();
    descriptionTFController.dispose();
  }

  Future<dynamic> getAllFoods() async {
    final accessToken = await Auth.getAccessToken();
    final res = await http.get(Uri.parse("http://10.0.2.2:1000/api/food"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $accessToken"});
    if (res.statusCode == 200) {
      foods = jsonDecode(res.body);
    } else {
      print("Get foods failed");
      foods = [];
    }
  }

  List<dynamic> findFoodSuggesstions(String search) {
    List<dynamic> suggesstions = [];
    for (int i = 0; i < foods.length; i++) {
      final food = foods[i];
      if (food["name"].toLowerCase().contains(search.toLowerCase())) {
        suggesstions.add({
          "id": food["_id"],
          "name": food["name"],
          "unitName": food["unitId"]["name"]
        });
      }
    }
    return suggesstions;
  }

  dynamic findMatchedFood(String search) {
    for (int i = 0; i < foods.length; i++) {
      final food = foods[i];
      if (food["name"].toLowerCase().compareTo(search.toLowerCase()) == 0) {
        return {
          "id": food["_id"],
          "name": food["name"],
          "unitName": food["unitId"]["name"]
        };
      }
    }
    return null;
  }

  final nameTFKey = GlobalKey();
  final ingredientsKey = GlobalKey();

  bool checkValidQuantity(String? quantity) {
    if (quantity == null || quantity.isEmpty) {
      return false;
    } else {
      final quantityInNumber = double.tryParse(quantity);
      if (quantityInNumber == null || quantityInNumber < 0) {
        return false;
      } else {
        return true;
      }
    }
  }

  Future<void> _successDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: const Text("Thêm công thức nấu ăn thành công"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge),
            )
          ],
        );
      },
    );
  }

  Future<void> _errorDialogBuilder(BuildContext context, String errorMessage) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Scrollable.ensureVisible(_formKey.currentContext!);
              },
              child: const Text("OK"),
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge),
            )
          ],
        );
      },
    );
  }

  Future<void> _loadingBuilder(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppBar(title: "Thêm công thức nấu ăn"),
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/recipe/recipe.png"),
                    width: 40,
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Tên công thức",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.5),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 0,
              child: TextFormField(
                controller: nameTFController,
                maxLines: null,
                decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                    filled: true,
                    contentPadding: EdgeInsets.all(10),
                    hintText: "Nhập tên công thức của bạn",
                    hintStyle: TextStyle(fontWeight: FontWeight.w400),
                    errorText: _nameTFError),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    setState(() {
                      _nameTFError = "Tên công thức không được bỏ trống";
                    });
                    return "Tên công thức không được bỏ trống";
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/recipe/harvest.png"),
                    width: 40,
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Nguyên liệu",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.5),
                    ),
                  )
                ],
              ),
            ),
            ListView.separated(
              itemCount: _ingredients.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var ingredient = _ingredients[index];
                // print("$_ingredients");
                final foodTFController = foodTFsControllers[index];
                final quantityTFController = quantityTFsControllers[index];
                return Row(
                  children: [
                    Flexible(
                      // fit: FlexFit.loose,
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: TypeAheadField(
                            controller: foodTFController,
                            builder: (context, controller, focusNode) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                    labelText: "Tên nguyên liệu",
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    filled: true,
                                    contentPadding: EdgeInsets.all(10),
                                    // hintText: (index == 0
                                    //     ? "VD: Thịt bò"
                                    //     : (index == 1 ? "VD: Hành tây" : "")),
                                    hintStyle:
                                        TextStyle(fontWeight: FontWeight.w400),
                                    errorMaxLines: 2),
                                validator: (foodName) {
                                  if (foodName == null || foodName.isEmpty) {
                                    if (quantityTFController.text.isNotEmpty) {
                                      return "Bạn phải điền tên nguyên liệu nếu đã điền số lượng!";
                                    } else {
                                      _ingredients[index] = {
                                        "food": {
                                          "id": "",
                                          "name": "",
                                          "unitName": ""
                                        },
                                        "quantity": ""
                                      };
                                      return null;
                                    }
                                  } else {
                                    final matchedFood =
                                        findMatchedFood(foodName);
                                    if (matchedFood == null) {
                                      return "Không tìm thấy nguyên liệu phù hợp!";
                                    } else {
                                      // setState(() {
                                      _ingredients[index]["food"]["id"] =
                                          matchedFood["id"];
                                      _ingredients[index]["food"]["name"] =
                                          matchedFood["name"];
                                      _ingredients[index]["food"]["unitName"] =
                                          matchedFood["unitName"];
                                      // });
                                      return null;
                                    }
                                  }
                                },
                              );
                            },
                            itemBuilder: (context, dynamic food) {
                              return ListTile(
                                title: Text(food["name"]),
                              );
                            },
                            onSelected: (dynamic food) {
                              setState(() {
                                foodTFController.text = food["name"];
                                _ingredients[index]["food"]["id"] = food["id"];
                                _ingredients[index]["food"]["name"] =
                                    food["name"];
                                _ingredients[index]["food"]["unitName"] =
                                    food["unitName"];
                              });
                            },
                            suggestionsCallback: findFoodSuggesstions,
                            emptyBuilder: (context) {
                              return const Padding(
                                padding: EdgeInsets.all(10),
                                child:
                                    Text("Không tìm thấy nguyên liệu phù hợp!"),
                              );
                            },
                          )),
                    ),
                    Flexible(
                      // fit: FlexFit.loose,
                      flex: 2,
                      child: TextFormField(
                        controller: quantityTFController,
                        decoration: InputDecoration(
                            labelText: "Số lượng",
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            filled: true,
                            contentPadding: EdgeInsets.all(10),
                            hintText: ingredient["food"]["id"] == ""
                                ? (index == 0
                                    ? "VD: 0.5 kg"
                                    : (index == 1 ? "VD: 1 củ" : ""))
                                : ("VD: 1 ${ingredient["food"]["unitName"]}"),
                            hintStyle: TextStyle(fontWeight: FontWeight.w400),
                            errorMaxLines: 2),
                        validator: (quantity) {
                          if (foodTFController.text.isNotEmpty) {
                            if (quantity == null || quantity.isEmpty) {
                              return "Bạn cần nhập số lượng của nguyên liệu!";
                            } else {
                              final unitName = _ingredients[index]["food"]
                                  ["unitName"] as String;
                              String quantityOnlyNumberInString = "";
                              quantity =
                                  quantity.toLowerCase().replaceAll(",", ".");

                              if (quantity.toLowerCase().contains(unitName)) {
                                String onlyQuantity =
                                    quantity.replaceFirst(unitName, '');
                                onlyQuantity = onlyQuantity.replaceAll(" ", "");
                                if (checkValidQuantity(onlyQuantity)) {
                                  quantityOnlyNumberInString = onlyQuantity;
                                } else {
                                  return "Không đúng định dạng số lượng nguyên liệu";
                                }
                              } else {
                                if (checkValidQuantity(quantity)) {
                                  quantityOnlyNumberInString = quantity;
                                } else {
                                  return "Không đúng định dạng số lượng nguyên liệu";
                                }
                              }
                              _ingredients[index]["quantity"] =
                                  quantityOnlyNumberInString;
                              return null;
                            }
                          } else {
                            return null;
                          }
                        },
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (context, index) => const Divider(
                height: 15,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Center(
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _ingredients.add({
                        "food": {"id": "", "name": "", "unitName": ""},
                        "quantity": ""
                      });
                      foodTFsControllers.add(TextEditingController());
                      quantityTFsControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 30,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 10, 0, 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/recipe/chef.png"),
                    width: 40,
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Nội dung công thức",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.5),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 0,
              child: TextFormField(
                controller: contentTFController,
                keyboardType: TextInputType.multiline,
                minLines: 8,
                maxLines: null,
                decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                    filled: true,
                    contentPadding: EdgeInsets.all(20),
                    hintText: "Nhập nội dung công thức của bạn",
                    hintStyle: TextStyle(fontWeight: FontWeight.w400)),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/recipe/information.png"),
                    width: 40,
                    height: 40,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Mô tả thêm",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17.5),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              flex: 0,
              child: TextFormField(
                controller: descriptionTFController,
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: null,
                decoration: InputDecoration(
                    fillColor: Theme.of(context).colorScheme.primaryContainer,
                    filled: true,
                    contentPadding: EdgeInsets.all(20),
                    hintText: "Mô tả thêm về công thức của bạn",
                    hintStyle: TextStyle(fontWeight: FontWeight.w400)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Hủy bỏ",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 15)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _nameTFError = null;
                      });
                      if (!_formKey.currentState!.validate()) {
                        Scrollable.ensureVisible(_formKey.currentContext!);
                      } else {
                        _loadingBuilder(context);
                        final result = await Provider.of<RecipeModel>(context,
                                listen: false)
                            .addRecipe(
                                nameTFController.text,
                                _ingredients,
                                contentTFController.text,
                                descriptionTFController.text);
                        if (result.contains("thành công")) {
                          _successDialogBuilder(context);
                        } else if (result.contains("đã tồn tại")) {
                          _errorDialogBuilder(context, "$result");
                          setState(() {
                            _nameTFError = result;
                          });
                        } else {
                          _errorDialogBuilder(
                              context, "$result\nXin vui lòng thử lại!");
                        }
                      }
                    },
                    child: Text(
                      "Thêm công thức",
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.fromLTRB(20, 15, 20, 15)),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 50),
              child: Text(""),
            )
          ],
        ),
      )),
    );
  }
}
