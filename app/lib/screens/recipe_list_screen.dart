import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'favorite_recipes_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Book', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoriteRecipesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                Provider.of<RecipeProvider>(context, listen: false).searchRecipes(value);
              },
            ),
          ),
          Consumer<RecipeProvider>(
            builder: (context, recipeProvider, child) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: ['All', 'Vegan', 'Vegetarian', 'Non-Vegetarian']
                        .map((filter) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: recipeProvider.selectedFilter == filter,
                                onSelected: (selected) {
                                  if (selected) {
                                    recipeProvider.setFilter(filter);
                                  }
                                },
                                selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<RecipeProvider>(
              builder: (context, recipeProvider, child) {
                if (recipeProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (recipeProvider.filteredRecipes.isEmpty) {
                  return const Center(child: Text('No recipes found'));
                }
                return ListView.builder(
                  itemCount: recipeProvider.filteredRecipes.length,
                  itemBuilder: (context, index) {
                    var recipeDoc = recipeProvider.filteredRecipes[index];
                    var recipe = recipeDoc.data() as Map<String, dynamic>;
                    recipe['id'] = recipeDoc.id;
                    return RecipeCard(
                      recipe: recipe,
                      isFavorite: recipeProvider.favoriteRecipes.contains(recipeDoc.id),
                      onFavoriteToggle: () => recipeProvider.toggleFavorite(recipeDoc.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(recipeId: recipeDoc.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}