import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/models/recipe.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:provider/provider.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key, required this.recipeId});

  final String recipeId;
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late final Future<dynamic> recipeFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recipeFuture = Provider.of<RecipeModel>(context, listen: false)
        .getRecipeById(widget.recipeId);
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

  Future<void> _linkToFridgeResultDialogBuilder(
      BuildContext context, dynamic result) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Kết quả liên kết"),
          content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                itemCount: result.length,
                itemBuilder: (context, index) {
                  final ingredientResult = result[index];
                  final state = ingredientResult["isSufficient"]
                      ? "Đủ số lượng"
                      : (ingredientResult["available"] > 0
                          ? "Thiếu số lượng"
                          : "Không có trong tủ lạnh");
                  final foodUnit = ingredientResult["foodUnit"];
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Nguyên liệu:  ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${ingredientResult["foodName"]}")
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Tình trạng:  ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(state),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: state == "Đủ số lượng"
                                ? Image(
                                    image: AssetImage(
                                      "assets/recipe/check.png",
                                    ),
                                    width: 20,
                                    height: 20,
                                  )
                                : Image(
                                    image: AssetImage(
                                      "assets/recipe/not.png",
                                    ),
                                    width: 20,
                                    height: 20,
                                  ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Số lượng cần trong công thức:  ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${ingredientResult["need"]} $foodUnit")
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "Số lượng có sẵn:  ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("${ingredientResult["available"]} $foodUnit")
                        ],
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 10);
                },
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: const MyAppBar(title: "Công thức nấu ăn"),
        body: FutureBuilder(
          future: recipeFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final recipe = snapshot.data!;
              final ingredients = recipe["ingredients"];
              final nameTFController = TextEditingController.fromValue(
                  TextEditingValue(text: recipe["name"]));

              final content = recipe["content"];
              var contentString = "";
              for (int i = 0; i < content.length; i++) {
                if (i == 0) {
                  contentString += "• " + content[i];
                } else {
                  contentString += "\n• " + content[i];
                }
              }
              final contentTFController = TextEditingController.fromValue(
                  TextEditingValue(text: contentString));

              final description = recipe["description"];
              var descriptionString = "";
              for (int i = 0; i < description.length; i++) {
                if (i == 0) {
                  descriptionString += "• " + description[i];
                } else {
                  descriptionString += "\n• " + description[i];
                }
              }
              final descriptionTFController = TextEditingController.fromValue(
                  TextEditingValue(text: descriptionString));

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
                      child: Row(
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
                      child: TextField(
                        controller: nameTFController,
                        readOnly: true,
                        maxLines: null,
                        decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            filled: true,
                            contentPadding: EdgeInsets.all(10)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
                      child: Row(
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
                    ingredients.length > 0
                        ? ListView.separated(
                            itemCount: ingredients.length,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var ingredient = ingredients[index];
                              final unitName =
                                  ingredient["foodId"]["unitId"]["name"];
                              final foodTFController =
                                  TextEditingController.fromValue(
                                      TextEditingValue(
                                          text: ingredient["foodId"]["name"]));
                              final quantityTFController =
                                  TextEditingController.fromValue(
                                      TextEditingValue(
                                          text: "${ingredient["quantity"]}" +
                                              " $unitName"));
                              return Row(
                                children: [
                                  Flexible(
                                    // fit: FlexFit.loose,
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: TextField(
                                        controller: foodTFController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                            labelText: "Tên nguyên liệu",
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            filled: true,
                                            contentPadding: EdgeInsets.all(10)),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    // fit: FlexFit.loose,
                                    flex: 2,
                                    child: TextField(
                                      controller: quantityTFController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          labelText: "Số lượng",
                                          fillColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          filled: true,
                                          contentPadding: EdgeInsets.all(10)),
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
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
                      child: Row(
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
                      child: TextField(
                        controller: contentTFController,
                        readOnly: true,
                        // keyboardType: TextInputType.multiline,
                        minLines: 6,
                        maxLines: null,
                        decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            filled: true,
                            contentPadding: EdgeInsets.all(20)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(15, 20, 0, 8),
                      child: Row(
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
                      child: TextField(
                        controller: descriptionTFController,
                        readOnly: true,
                        // keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: null,
                        decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            filled: true,
                            contentPadding: EdgeInsets.all(20)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              _loadingBuilder(context);
                              final result = await Provider.of<RecipeModel>(
                                      context,
                                      listen: false)
                                  .connectRecipeWithFridge(widget.recipeId);
                              Navigator.pop(context);
                              if (result ==
                                  "Đã có lỗi xảy ra trong quá trình liên kết công thức nấu ăn với tủ lạnh.") {
                                _errorDialogBuilder(context, result);
                              } else {
                                _linkToFridgeResultDialogBuilder(
                                    context, result);
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  image: AssetImage("assets/fridge.png"),
                                  width: 30,
                                  height: 30,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text("Liên kết công thức với tủ lạnh"),
                                )
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15)),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 40),
                      child: Text(""),
                    )
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
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
