import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _imageUrl = '';
  final List<String> _ingredients = [''];
  final List<String> _instructions = [''];
  String _cookingTime = '';
  String _type = 'Non-Vegetarian';

  void _addIngredient() {
    setState(() {
      _ingredients.add('');
    });
  }

  void _addInstruction() {
    setState(() {
      _instructions.add('');
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<RecipeProvider>(context, listen: false).addRecipe({
        'name': _name.toLowerCase(),
        'displayName': _name,
        'description': _description,
        'image_url': _imageUrl,
        'ingredients': _ingredients,
        'instructions': _instructions,
        'cooking_time': _cookingTime,
        'type': _type,
        'createdAt': DateTime.now(),
        'ratings': [],
        'averageRating': 0.0,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Recipe Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              onSaved: (value) => _name = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              onSaved: (value) => _description = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Image URL'),
              validator: (value) => value!.isEmpty ? 'Please enter an image URL' : null,
              onSaved: (value) => _imageUrl = value!,
            ),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Recipe Type'),
              items: <String>['Vegan', 'Vegetarian', 'Non-Vegetarian']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _type = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            ..._ingredients.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Ingredient ${entry.key + 1}'),
                        validator: (value) => value!.isEmpty ? 'Please enter an ingredient' : null,
                        onSaved: (value) => _ingredients[entry.key] = value!,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _ingredients.removeAt(entry.key);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            ElevatedButton(
              onPressed: _addIngredient,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add Ingredient'),
            ),
            const SizedBox(height: 16),
            Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
            ..._instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Instruction ${entry.key + 1}'),
                        validator: (value) => value!.isEmpty ? 'Please enter an instruction' : null,
                        onSaved: (value) => _instructions[entry.key] = value!,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _instructions.removeAt(entry.key);
                        });
                      },
                    ),
                  ],
                ),
              );
            }),
            ElevatedButton(
              onPressed: _addInstruction,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add Instruction'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cooking Time'),
              validator: (value) => value!.isEmpty ? 'Please enter cooking time' : null,
              onSaved: (value) => _cookingTime = value!,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}