import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> _recipes = [];
  List<QueryDocumentSnapshot> get recipes => _recipes;

  List<QueryDocumentSnapshot> _filteredRecipes = [];
  List<QueryDocumentSnapshot> get filteredRecipes => _filteredRecipes;

  Set<String> _favoriteRecipes = {};
  Set<String> get favoriteRecipes => _favoriteRecipes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  String _searchQuery = '';

  Future<void> loadRecipes() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .orderBy('createdAt', descending: true)  // Sort by creation time, newest first
          .get();

      _recipes = querySnapshot.docs;
      await _loadFavorites();
      _applyFilters();
    } catch (e) {
      print("Error fetching recipes: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteRecipes = prefs.getStringList('favorites')?.toSet() ?? {};
  }

  Future<void> toggleFavorite(String recipeId) async {
    if (_favoriteRecipes.contains(recipeId)) {
      _favoriteRecipes.remove(recipeId);
    } else {
      _favoriteRecipes.add(recipeId);
    }
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteRecipes.toList());
    
    notifyListeners();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void searchRecipes(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRecipes = _recipes.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      bool matchesFilter = _selectedFilter == 'All' || data['type'] == _selectedFilter;
      bool matchesSearch = _searchQuery.isEmpty ||
          data['name'].toString().toLowerCase().contains(_searchQuery) ||
          data['description'].toString().toLowerCase().contains(_searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Map<String, dynamic>? getRecipeById(String id) {
    try {
      final recipeDoc = _recipes.firstWhere((doc) => doc.id == id);
      return recipeDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print("Recipe not found: $e");
      return null;
    }
  }

  Future<void> addRecipe(Map<String, dynamic> recipe) async {
    try {
      // Add createdAt field with current server timestamp
      recipe['createdAt'] = FieldValue.serverTimestamp();
      
      // Add the recipe to Firestore
      await FirebaseFirestore.instance.collection('recipes').add(recipe);
      
      // Reload recipes to include the new one
      await loadRecipes();
    } catch (e) {
      print("Error adding recipe: $e");
      rethrow;
    }
  }

  Future<void> updateRating(String recipeId, int rating) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
    
    await docRef.update({
      'rating': rating,
    });

    // Update local data
    await loadRecipes();  // Reload all recipes to ensure consistency
    notifyListeners();
  }
}