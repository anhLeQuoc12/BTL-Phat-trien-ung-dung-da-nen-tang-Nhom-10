import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend_flutter_app/data/auth.dart';
import 'package:frontend_flutter_app/models/recipe.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import "package:http/http.dart" as http;
import 'package:provider/provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final String recipeId;
  const EditRecipeScreen({super.key, required this.recipeId});

  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Future<dynamic> recipeFuture;
  dynamic _recipe = {"_id": ""};
  final nameTFController = TextEditingController();
  final contentTFController = TextEditingController();
  final descriptionTFController = TextEditingController();
  List<dynamic> _ingredients = [];
  List<TextEditingController> foodTFsControllers = [];
  List<TextEditingController> quantityTFsControllers = [];
  late final List foods;

  String? _nameTFError = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recipeFuture = Provider.of<RecipeModel>(context, listen: false)
        .getRecipeById(widget.recipeId);
    getAllFoods();
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

  bool checkNameChanged() {
    return _recipe["name"] != nameTFController.text.trim();
  }

  bool checkIngredientsChanged() {
    final newIngredients = _ingredients
        .where((ingredient) => ingredient["food"]["id"].isNotEmpty)
        .toList();
    if (_recipe["ingredients"].length != newIngredients.length) {
      return true;
    } else {
      for (int i = 0; i < newIngredients.length; i++) {
        final oldIngredient = _recipe["ingredients"][i];
        final newIngredient = newIngredients[i];
        if (oldIngredient["foodId"]["_id"] != newIngredient["food"]["id"] ||
            oldIngredient["quantity"].toString() != newIngredient["quantity"]) {
          return true;
        }
      }
      return false;
    }
  }

  bool checkContentChanged() {
    final oldContent = _recipe["content"];
    var oldContentString = "";
    for (int i = 0; i < oldContent.length; i++) {
      if (i == 0) {
        oldContentString += oldContent[i];
      } else {
        oldContentString += "\n" + oldContent[i];
      }
    }
    return oldContentString != contentTFController.text;
  }

  bool checkDescriptionChanged() {
    final oldDescription = _recipe["description"];
    var oldDescriptionString = "";
    for (int i = 0; i < oldDescription.length; i++) {
      if (i == 0) {
        oldDescriptionString += oldDescription[i];
      } else {
        oldDescriptionString += "\n" + oldDescription[i];
      }
    }
    return oldDescriptionString != descriptionTFController.text;
  }

  Future<void> _successDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: const Text("Sửa công thức nấu ăn thành công"),
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

  Future<void> _errorDialogBuilder(
      BuildContext context, String errorMessage, bool isPendingBefore) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                if (isPendingBefore) {
                  Navigator.pop(context);
                }
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
        appBar: MyAppBar(title: "Sửa công thức nấu ăn"),
        body: FutureBuilder(
          future: recipeFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (_recipe["_id"].isEmpty) {
                _recipe = snapshot.data!;
                nameTFController.text = _recipe["name"];
                final ingredients = _recipe["ingredients"];
                _ingredients.addAll(ingredients.map((ingredient) {
                  return {
                    "food": {
                      "id": ingredient["foodId"]["_id"],
                      "name": ingredient["foodId"]["name"],
                      "unitName": ingredient["foodId"]["unitId"]["name"]
                    },
                    "quantity": ingredient["quantity"].toString()
                  };
                }));
                for (int i = 0; i < _ingredients.length; i++) {
                  final ingredient = _ingredients[i];
                  foodTFsControllers.add(
                      TextEditingController(text: ingredient["food"]["name"]));
                  quantityTFsControllers
                      .add(TextEditingController(text: ingredient["quantity"]));
                }

                final content = _recipe["content"];
                var contentString = "";
                for (int i = 0; i < content.length; i++) {
                  if (i == 0) {
                    contentString += content[i];
                  } else {
                    contentString += "\n" + content[i];
                  }
                }
                contentTFController.text = contentString;
                final description = _recipe["description"];
                var descriptionString = "";
                for (int i = 0; i < description.length; i++) {
                  if (i == 0) {
                    descriptionString += description[i];
                  } else {
                    descriptionString += "\n" + description[i];
                  }
                }
                descriptionTFController.text = descriptionString;
              }

              return SingleChildScrollView(
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
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            filled: true,
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Nhập tên công thức của bạn",
                            hintStyle: TextStyle(fontWeight: FontWeight.w400),
                            errorText: _nameTFError),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            setState(() {
                              _nameTFError =
                                  "Tên công thức không được bỏ trống";
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
                    _ingredients.isNotEmpty
                        ? ListView.separated(
                            itemCount: _ingredients.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var ingredient = _ingredients[index];
                              final foodTFController =
                                  foodTFsControllers[index];
                              final quantityTFController =
                                  quantityTFsControllers[index];
                              return Row(
                                children: [
                                  Flexible(
                                    // fit: FlexFit.loose,
                                    flex: 3,
                                    child: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: TypeAheadField(
                                          controller: foodTFController,
                                          builder:
                                              (context, controller, focusNode) {
                                            return TextFormField(
                                              controller: controller,
                                              focusNode: focusNode,
                                              decoration: InputDecoration(
                                                  labelText: "Tên nguyên liệu",
                                                  fillColor: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer,
                                                  filled: true,
                                                  contentPadding:
                                                      EdgeInsets.all(10),
                                                  // hintText: (index == 0
                                                  //     ? "VD: Thịt bò"
                                                  //     : (index == 1 ? "VD: Hành tây" : "")),
                                                  hintStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  errorMaxLines: 2),
                                              validator: (foodName) {
                                                if (foodName == null ||
                                                    foodName.isEmpty) {
                                                  if (quantityTFController
                                                      .text.isNotEmpty) {
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
                                                    _ingredients[index]["food"]
                                                            ["id"] =
                                                        matchedFood["id"];
                                                    _ingredients[index]["food"]
                                                            ["name"] =
                                                        matchedFood["name"];
                                                    _ingredients[index]["food"]
                                                            ["unitName"] =
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
                                              foodTFController.text =
                                                  food["name"];
                                              _ingredients[index]["food"]
                                                  ["id"] = food["id"];
                                              _ingredients[index]["food"]
                                                  ["name"] = food["name"];
                                              _ingredients[index]["food"]
                                                      ["unitName"] =
                                                  food["unitName"];
                                            });
                                          },
                                          suggestionsCallback:
                                              findFoodSuggesstions,
                                          emptyBuilder: (context) {
                                            return const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                  "Không tìm thấy nguyên liệu phù hợp!"),
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
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          filled: true,
                                          contentPadding: EdgeInsets.all(10),
                                          hintText: ingredient["food"]["id"] ==
                                                  ""
                                              ? (index == 0
                                                  ? "VD: 0.5 kg"
                                                  : (index == 1
                                                      ? "VD: 1 củ"
                                                      : ""))
                                              : ("VD: 1 ${ingredient["food"]["unitName"]}"),
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w400),
                                          errorMaxLines: 2),
                                      validator: (quantity) {
                                        if (foodTFController.text.isNotEmpty) {
                                          if (quantity == null ||
                                              quantity.isEmpty) {
                                            return "Bạn cần nhập số lượng của nguyên liệu!";
                                          } else {
                                            final unitName = _ingredients[index]
                                                ["food"]["unitName"] as String;
                                            String quantityOnlyNumberInString =
                                                "";
                                            quantity = quantity
                                                .toLowerCase()
                                                .replaceAll(",", ".");

                                            if (quantity
                                                .toLowerCase()
                                                .contains(unitName)) {
                                              String onlyQuantity = quantity
                                                  .replaceFirst(unitName, '');
                                              onlyQuantity = onlyQuantity
                                                  .replaceAll(" ", "");
                                              if (checkValidQuantity(
                                                  onlyQuantity)) {
                                                quantityOnlyNumberInString =
                                                    onlyQuantity;
                                              } else {
                                                return "Không đúng định dạng số lượng nguyên liệu";
                                              }
                                            } else {
                                              if (checkValidQuantity(
                                                  quantity)) {
                                                quantityOnlyNumberInString =
                                                    quantity;
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
                          )
                        : const Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: Text(
                              "Chưa có nguyên liệu",
                              style: TextStyle(fontStyle: FontStyle.italic),
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
                              quantityTFsControllers
                                  .add(TextEditingController());
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
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
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
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _nameTFError = null;
                              });
                              if (!_formKey.currentState!.validate()) {
                                Scrollable.ensureVisible(
                                    _formKey.currentContext!);
                              } else {
                                final isNameChanged = checkNameChanged();
                                final isIngredientsChanged =
                                    checkIngredientsChanged();
                                final isContentChanged = checkContentChanged();
                                final isDescriptionChanged =
                                    checkDescriptionChanged();
                                if (!isNameChanged &&
                                    !isIngredientsChanged &&
                                    !isContentChanged &&
                                    !isDescriptionChanged) {
                                  _errorDialogBuilder(context,
                                      "Công thức chưa được thay đổi.", false);
                                } else {
                                  _loadingBuilder(context);
                                  final result = await Provider.of<RecipeModel>(
                                          context,
                                          listen: false)
                                      .updateRecipeById(
                                          widget.recipeId,
                                          isNameChanged
                                              ? nameTFController.text
                                              : null,
                                          isIngredientsChanged
                                              ? _ingredients
                                              : null,
                                          isContentChanged
                                              ? contentTFController.text
                                              : null,
                                          isDescriptionChanged
                                              ? descriptionTFController.text
                                              : null);
                                  if (result.contains("thành công")) {
                                    _successDialogBuilder(context);
                                  } else if (result.contains("đã tồn tại")) {
                                    _errorDialogBuilder(
                                        context, "$result", true);
                                    setState(() {
                                      _nameTFError = result;
                                    });
                                  } else {
                                    _errorDialogBuilder(context,
                                        "$result\nXin vui lòng thử lại!", true);
                                  }
                                }
                              }
                            },
                            child: Text(
                              "Sửa công thức",
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
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
              ));
            } else if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Text(
                      "Đã có lỗi xảy ra trong quá trình lấy dữ liệu công thức cho việc sửa công thức."),
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
        ));
  }
}
