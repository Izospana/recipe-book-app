import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _instructionControllers = [TextEditingController()];
  final _cookingTimeController = TextEditingController();
  String _type = 'Non-Vegetarian';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _instructionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _addInstruction() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final recipe = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image_url': _imageUrlController.text,
        'ingredients': _ingredientControllers.map((c) => c.text).toList(),
        'instructions': _instructionControllers.map((c) => c.text).toList(),
        'type': _type,
        'cooking_time': _cookingTimeController.text,
      };

      try {
        await Provider.of<RecipeProvider>(context, listen: false).addRecipe(recipe);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recipe added successfully!'), backgroundColor: Colors.orange),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe. Please try again.'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildDynamicList(String title, List<TextEditingController> controllers, Function() addFunction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...controllers.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.value,
                        decoration: InputDecoration(
                          labelText: '${title.substring(0, title.length - 1)} ${entry.key + 1}',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        validator: (value) => value!.isEmpty ? 'This field is required' : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => setState(() => controllers.removeAt(entry.key)),
                    ),
                  ],
                ),
              ),
            ),
        TextButton.icon(
          onPressed: addFunction,
          icon: Icon(Icons.add, color: Colors.orange),
          label: Text('Add ${title.substring(0, title.length - 1)}', style: TextStyle(color: Colors.orange)),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_nameController, 'Recipe Name'),
                _buildTextField(_descriptionController, 'Description', maxLines: 3),
                _buildTextField(_imageUrlController, 'Image URL'),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(
                    labelText: 'Recipe Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  items: ['Vegan', 'Vegetarian', 'Non-Vegetarian']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                SizedBox(height: 16),
                _buildDynamicList('Ingredients', _ingredientControllers, _addIngredient),
                _buildDynamicList('Instructions', _instructionControllers, _addInstruction),
                _buildTextField(_cookingTimeController, 'Cooking Time'),
                SizedBox(height: 24),
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.orange))
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Submit Recipe', style: TextStyle(fontSize: 18)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}