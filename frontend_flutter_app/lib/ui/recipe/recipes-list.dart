import 'package:flutter/material.dart';
import 'package:frontend_flutter_app/models/recipe.dart';
import 'package:frontend_flutter_app/ui/app-bar.dart';
import 'package:frontend_flutter_app/ui/drawer.dart';
import 'package:frontend_flutter_app/ui/recipe/add-recipe.dart';
import 'package:frontend_flutter_app/ui/recipe/edit-recipe.dart';
import 'package:frontend_flutter_app/ui/recipe/recipe.dart';
import 'package:provider/provider.dart';

class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: const MyAppBar(title: "Công thức nấu ăn"),
      drawer: const MyAppDrawer(),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  Image(
                    image: AssetImage("assets/recipe/recipe.png"),
                    width: 40,
                    height: 40,
                  ),
                  Container(
                    child: Text(
                      "Danh sách các công thức nấu ăn của bạn:",
                      style: TextStyle(fontSize: 17),
                    ),
                    width: 220,
                    padding: EdgeInsets.only(left: 10),
                  ),
                ]),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddRecipeScreen(),
                          ));
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 30,
                    ))
              ],
            ),
          ),
          const RecipesList()
        ],
      ),
    );
  }
}

class RecipesList extends StatelessWidget {
  const RecipesList({super.key});

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

  Future<void> _successDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: const Text("Xóa công thức nấu ăn thành công."),
          actions: [
            TextButton(
              onPressed: () {
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

  Future<void> _deleteDialogBuilder(
      BuildContext context, String recipeId, String recipeName) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xóa công thức nấu ăn"),
          content: Text(
              "Bạn có chắc chắn muốn xóa công thức nấu ăn \"$recipeName\" ?"),
          actions: [
            TextButton(
              onPressed: () async {
                _loadingBuilder(context);
                final result =
                    await Provider.of<RecipeModel>(context, listen: false)
                        .deleteRecipeById(recipeId);
                Navigator.pop(context);
                Navigator.pop(context);
                if (result.contains("thành công")) {
                  _successDialogBuilder(context);
                } else {
                  _errorDialogBuilder(context, result);
                }
              },
              child: const Text("Xóa"),
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.error,
                // padding: EdgeInsets.fromLTRB(20, 11, 20, 11)
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy bỏ"),
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                // padding: EdgeInsets.fromLTRB(20, 11, 20, 11)
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<RecipeModel>(
      builder: (context, value, child) {
        return FutureBuilder(
          future: value.getRecipesList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final recipesList = snapshot.data!;
              if (recipesList.length > 0) {
                return Expanded(
                  child: ListView.separated(
                    itemCount: recipesList.length,
                    itemBuilder: (context, index) {
                      var recipe = recipesList[index];
                      return ListTile(
                        tileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        title: Text(
                          recipe["name"],
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: recipe["content"].length > 0
                            ? Text(
                                recipe["content"][0] +
                                    (recipe["content"].length > 1 ? "..." : ""),
                                style: const TextStyle(
                                    // fontSize: 20,
                                    fontWeight: FontWeight.w400),
                                overflow: TextOverflow.ellipsis,
                              )
                            : const Text(
                                "Chưa có nội dung",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                        trailing: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                        builder: (context) => EditRecipeScreen(
                                            recipeId: recipe["_id"])));
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () {
                                _deleteDialogBuilder(
                                    context, recipe["_id"], recipe["name"]);
                              },
                              icon: const Icon(Icons.delete),
                            )
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) =>
                                      RecipeScreen(recipeId: recipe["_id"])));
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 2,
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text(
                        "Bạn chưa có công thức nào.\nHãy tạo một công thức!"),
                  ),
                );
              }
            } else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(40, 100, 40, 100),
                      child: Text("${snapshot.error}"))
                ],
              );
            }

            return const Padding(
              padding: EdgeInsets.only(top: 140),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
