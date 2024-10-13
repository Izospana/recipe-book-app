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

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  String _searchQuery = '';

  DocumentSnapshot? _lastDocument;
  int _limit = 5;

  int get limit => _limit;
  set limit(int value) {
    if (value > 0) {
      _limit = value;
      loadRecipes(refresh: true);
    }
  }

  Future<void> loadRecipes({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _recipes.clear();
      _lastDocument = null;
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      Query query = FirebaseFirestore.instance
          .collection('recipes')
          .orderBy('createdAt', descending: true);

      if (_selectedFilter != 'All') {
        query = query.where('type', isEqualTo: _selectedFilter);
      }

      query = query.limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.length < _limit) {
        _hasMore = false;
      }

      _recipes.addAll(querySnapshot.docs);
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }

      await _loadFavorites();
      _applyFilters();
    } catch (e) {
      print("Error fetching recipes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _favoriteRecipes = prefs.getStringList('favorites')?.toSet() ?? {};
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    try {
      if (_favoriteRecipes.contains(recipeId)) {
        _favoriteRecipes.remove(recipeId);
      } else {
        _favoriteRecipes.add(recipeId);
      }
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favoriteRecipes.toList());
      
      notifyListeners();
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    loadRecipes(refresh: true);
  }

  void searchRecipes(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    _hasMore = false; // Disable lazy loading during search
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRecipes = _recipes.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      bool matchesSearch = _searchQuery.isEmpty ||
          data['name'].toString().toLowerCase().contains(_searchQuery) ||
          data['description'].toString().toLowerCase().contains(_searchQuery);
      return matchesSearch;
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
      recipe['createdAt'] = FieldValue.serverTimestamp();
      DocumentReference docRef = await FirebaseFirestore.instance.collection('recipes').add(recipe);
      
      DocumentSnapshot newRecipe = await docRef.get();
      
      if (newRecipe.exists) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('recipes')
            .where(FieldPath.documentId, isEqualTo: newRecipe.id)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          _recipes.insert(0, querySnapshot.docs.first);
          _applyFilters();
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error adding recipe: $e");
      rethrow;
    }
  }

  Future<void> updateRating(String recipeId, int rating) async {
    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
      
      await docRef.update({
        'rating': rating,
      });

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where(FieldPath.documentId, isEqualTo: recipeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        int index = _recipes.indexWhere((doc) => doc.id == recipeId);
        if (index != -1) {
          _recipes[index] = querySnapshot.docs.first;
          _applyFilters();
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error updating rating: $e");
      rethrow;
    }
  }
}