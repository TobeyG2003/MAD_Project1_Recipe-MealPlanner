import 'package:flutter/material.dart';
import '../database_setup.dart';

class MealPlannerScreen extends StatefulWidget {
  final VoidCallback? onGroceryListGenerated;
  const MealPlannerScreen({super.key, this.onGroceryListGenerated});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();

}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> meals = []; // meals assigned to each day
  late Future<List<Map<String, dynamic>>> groceryList;


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
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    await dbHelper.init();
    final saved = await dbHelper.getRecipesfromMeals();
    setState(() { // update ui w/ db results
      meals = saved; 
      groceryList = dbHelper.getGrocerylistfromallMeals(); 
    });
  }

  Future<void> _savePlan() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan saved!')),
    );
  }

  Future<void> _generateGroceryList() async {
      groceryList = dbHelper.getGrocerylistfromallMeals(); // refreshes list based on what's in the plan
      setState(() {});
      widget.onGroceryListGenerated?.call(); // Notify parent widget
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grocery List Updated!')),
      );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: const Color.fromARGB(255, 188, 44, 44),
      ),
      body: ListView.builder(
        itemCount: days.length,
        itemBuilder: (context, index) {
          if (meals.isEmpty) {
            return ListTile(
              title: Text(days[index],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('No recipe selected'),
            );
          }

          final meal = meals[index];
          final recipeName = meal['name'];
          final hasRecipe = recipeName != null;

          return ListTile(
            title: Text(
              days[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              hasRecipe ? recipeName : 'No recipe selected',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: hasRecipe ? Colors.red : Colors.grey,
              tooltip: 'Clear',
              onPressed: hasRecipe // clear meal button
                  ? () async {
                      final mealId = index + 1;
                      await dbHelper.clearMeal(mealId);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cleared ${days[index]}')),
                      );
                      _loadMeals();
                    }
                  : null,
            ),
           
               
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
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
            ElevatedButton.icon(
              onPressed: _generateGroceryList,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
              ),
              icon: const Icon(Icons.list),
              label: const Text('Generate Grocery List'),
            ),
          ],
        ),
      ),
    );
  }
}
