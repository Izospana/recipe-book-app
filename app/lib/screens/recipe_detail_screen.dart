import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/star_rating.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeProvider>(
      builder: (context, recipeProvider, child) {
        final recipe = recipeProvider.getRecipeById(recipeId);
        
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Recipe not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe['displayName'] ?? recipe['name'] ?? 'Unnamed Recipe',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        recipe['image_url'] ?? 'https://via.placeholder.com/300x200',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      recipeProvider.favoriteRecipes.contains(recipeId) ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () => recipeProvider.toggleFavorite(recipeId),
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Rate this recipe:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        StarRating(
                          rating: recipe['rating'] ?? 0,
                          onRatingChanged: (rating) {
                            int newRating = (recipe['rating'] ?? 0) == rating ? rating - 1 : rating;
                            recipeProvider.updateRating(recipeId, newRating);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(newRating > 0
                                    ? 'You rated this recipe $newRating star${newRating > 1 ? 's' : ''}!'
                                    : 'You removed your rating for this recipe.'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          color: Colors.green,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.list, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Ingredients:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...(recipe['ingredients'] as List<dynamic>).map((ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.fiber_manual_record, size: 8, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(ingredient.toString())),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.menu_book, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...(recipe['instructions'] as List<dynamic>).asMap().entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.green,
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(entry.value.toString())),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Cooking Time: ${recipe['cooking_time']}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}