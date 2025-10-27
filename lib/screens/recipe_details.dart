import 'package:flutter/material.dart';
import '../database_setup.dart';
import '../main.dart' show dbHelper; // using existing db
import 'package:share_plus/share_plus.dart';


class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailScreen> {
  final db = dbHelper; 
  Map<String, dynamic>? recipe;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> instructions = [];
  List<Map<String, dynamic>> tags = [];

  final days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {

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
      orderBy: 'stepNumber ASC', // makes sure it's in order
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
      tags = tagResult; // setting tags
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
                recipe!['imageURl'],
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
                ElevatedButton(
                    onPressed: () async {
                  

                      await db.toggleFavorite(widget.recipeId);  // update db
                      bool status = await db.getFavoriteStatus(widget.recipeId); // fetch new value

                      setState(() {
                       recipe = {...recipe!, 'recipefavorite': status ? 1 : 0,};
                      });
                    },

                  child: Text( // changing the button from favorite to unfavorite and vice versa
                  recipe!['recipefavorite'] == 1 ? 'Unfavorite' : 'Favorite'
                ),
             ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {
                  Share.share(
                    'Check out this recipe! ${recipe!['name']}',
                    subject: 'Recipe from my Recipe App',
                  );
                }, child: const Text('Share')),
              ],
            ),

            const SizedBox(height: 20),

            // adding recipe to specific day
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Add to Meal Plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 8),

            // buttons for meal plan
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(days.length, (index) {
                final day = days[index];
                final mealId = index + 1;
                return ElevatedButton(
                  onPressed: () async {
                    await db.updateMeal(mealId, widget.recipeId);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to $day')),
                    );
                  },
                  child: Text(day),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ingredients section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Ingredients',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 6),
            ...ingredients.map((i) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- ${i['quantity']} ${i['unit']} ${i['name']} ', // ingredient measurements
                  ),
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
                child: Text(
                  '$index. ${step['description']}', 
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
