import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> details;
  const RecipeDetailScreen({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final recipe = details['recipe'];
    final ingredients = details['ingredients'] as List;
    final steps = details['instructions'] as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
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
                'assets/images/${recipe['image']}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            // tags for diet like vegan, vegetarian, gluten free
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(recipe['diet_type']),
                  backgroundColor: Colors.green.shade100,
                ),
              ],
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
            ...steps.asMap().entries.map((entry) {
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
