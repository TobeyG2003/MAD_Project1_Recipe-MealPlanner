import 'package:flutter/material.dart';
import '../database_setup.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailsScreenState();
}
  class _RecipeDetailsScreenState extends State<RecipeDetailScreen> {
    final db = DatabaseHelper();
    Map<String, dynamic>? recipe;
    List<Map<String, dynamic>> ingredients = [];
    List<Map<String, dynamic>> instructions = [];
    List<Map<String, dynamic>> tags = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await db.init();

    final recipeResult = await db.recipesdb.query(
      'recipestable',
      where: 'id = ?',
      whereArgs: [widget.recipeId],
    );
    final ingredientResult = await db.ingredientsdb.query(
      'ingredientstable',
      where: 'recipeId = ?',
      whereArgs: [widget.recipeId],
    );
    final instructionResult = await db.instructionsdb.query(
      'instructionstable',
      where: 'recipeId = ?',
      whereArgs: [widget.recipeId],
    );

    // getting diet tags using join, making tagstable t and recipetag rt 
    final tagResult = await db.recipetagsdb.rawQuery(''' 
        SELECT t.name
        FROM recipetagstable rt
        JOIN tagstable t on rt.tagId = t.id
        WHERE rt.recipeId = ?
    ''', [widget.recipeId]);

    setState(() {
      recipe = recipeResult.isNotEmpty ? recipeResult.first : null;
      ingredients = ingredientResult;
      instructions = instructionResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (recipe == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
   
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe!['name']),
        backgroundColor: const Color.fromARGB(255, 188, 44, 44),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // image of recipe
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/${recipe!['imageURL']}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            // tags for diet like vegan, vegetarian, gluten free
            Wrap(
              spacing: 8,
              children: tags.map((t) => Chip(
              label: Text(t['name']),
              backgroundColor: Colors.green.shade100,
            )).toList(),
            ),
            const SizedBox(height: 10),

            // buttons below recipe
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Favorite')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Meal Plan')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Share')),
              ],
            ),

            const SizedBox(height: 20),

            // ingredients section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ingredients',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 6),
            ...ingredients.map((i) => Align( // creates text widget for every ingredient and puts them on its own line
                  alignment: Alignment.centerLeft,
                  child: Text('- $i'),
                )),

            const SizedBox(height: 20),

            // instructions section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 6),
            ...instructions.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final step = entry.value;
              return Align(
                alignment: Alignment.centerLeft,
                child: Text('$index. $step'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
