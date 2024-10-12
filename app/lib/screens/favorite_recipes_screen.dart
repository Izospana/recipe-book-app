import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoriteRecipesScreen extends StatelessWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, child) {
          if (recipeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final favoriteRecipes = recipeProvider.recipes.where(
            (recipe) => recipeProvider.favoriteRecipes.contains(recipe.id)
          ).toList();

          if (favoriteRecipes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorite recipes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some recipes to your favorites!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteRecipes.length,
            itemBuilder: (context, index) {
              var recipeDoc = favoriteRecipes[index];
              var recipe = recipeDoc.data() as Map<String, dynamic>;
              recipe['id'] = recipeDoc.id;
              return RecipeCard(
                recipe: recipe,
                isFavorite: true,
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
    );
  }
}