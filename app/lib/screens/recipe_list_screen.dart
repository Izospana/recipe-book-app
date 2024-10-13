import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';
import 'favorite_recipes_screen.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<RecipeProvider>(context, listen: false).loadRecipes();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Book', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoriteRecipesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: Icon(Icons.search, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: ['All', 'Vegan', 'Vegetarian', 'Non-Vegetarian']
                        .map((filter) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: recipeProvider.selectedFilter == filter,
                                onSelected: (selected) {
                                  if (selected) {
                                    recipeProvider.setFilter(filter);
                                  }
                                },
                                selectedColor: Colors.orange.withOpacity(0.3),
                                checkmarkColor: Colors.orange,
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
                if (recipeProvider.isLoading && recipeProvider.recipes.isEmpty) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: recipeProvider.filteredRecipes.length + (recipeProvider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == recipeProvider.filteredRecipes.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
                        ),
                      );
                    }
                    var recipe = recipeProvider.filteredRecipes[index].data() as Map<String, dynamic>;
                    recipe['id'] = recipeProvider.filteredRecipes[index].id;
                    return RecipeCard(
                      recipe: recipe,
                      isFavorite: recipeProvider.favoriteRecipes.contains(recipe['id']),
                      onFavoriteToggle: () => recipeProvider.toggleFavorite(recipe['id']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(recipeId: recipe['id']),
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipeScreen()),
          );
          _scrollToTop();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}