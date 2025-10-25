import 'package:flutter/material.dart';
import '../database_setup.dart';
import '../helpers/mealplan_helper.dart'; 

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final dbHelper = DatabaseHelper();
  final plannerHelper = MealPlannerHelper();

  List<Map<String, dynamic>> recipes = [];
  Map<String, int?> selectedRecipes = {
    'Sunday': null,
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
  };

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    await dbHelper.init(); // initialize all dbs
    final data = await dbHelper.recipesdb.query('recipestable');
    setState(() {
      recipes = data;
    });
  }
// message at bottom
  Future<void> _savePlan() async {
    await plannerHelper.savePlan(selectedRecipes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan saved!')),
    );
  }

 /* Future<void> _generateGroceryList() async {
    final ingredients = await plannerHelper.generateGroceryList();
    if (!mounted) return; // if user isn't on screen, stop

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroceryListScreen(ingredients: ingredients),
      ),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: const Color.fromARGB(255, 188, 44, 44),
      ),
      body: ListView(
        children: selectedRecipes.keys.map((day) {
          return ListTile(
            title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: DropdownButton<int?>(
              value: selectedRecipes[day],
              hint: const Text('Select Recipe'),
              items: recipes
                  .map((r) => DropdownMenuItem(
                        value: r['id'] as int,
                        child: Text(r['name']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRecipes[day] = value;
                });
              },
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _savePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 188, 44, 44),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Save Plan'),
            ),
           /* ElevatedButton.icon(
              onPressed: _generateGroceryList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
              ),
              icon: const Icon(Icons.list),
              label: const Text('Grocery List'),
            ), */
          ],
        ),
      ),
    );
  }
}
