import 'package:sqflite/sqflite.dart';
import '../database_setup.dart';

class MealPlannerHelper {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<void> createPlannerTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS meal_planner (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day TEXT,
        recipe_id INTEGER,
        FOREIGN KEY (recipe_id) REFERENCES recipestable(id)
      )
    ''');
  }
  Future<void> savePlan(Map<String, int?> selectedRecipes) async {
    final db = await openDatabase('mealplanner.db', version: 1,
        onCreate: (db, version) async {
      await createPlannerTable(db);
    });

    for (final entry in selectedRecipes.entries) {
      if (entry.value != null) {
        await db.insert(
          'meal_planner',
          {'day': entry.key, 'recipe_id': entry.value},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> getPlannedMeals() async {
    final db = await openDatabase('mealplanner.db');
    return db.query('meal_planner');
  }

  Future<List<Map<String, dynamic>>> generateGroceryList() async {
    final db = await openDatabase('mealplanner.db');
    final plannerRows = await db.query('meal_planner');
    if (plannerRows.isEmpty) return [];
    final recipeIds = plannerRows.map((e) => e['recipe_id']).toList();
    // getting ingredients from ingredientsdb
    final ingredientRows = await dbHelper.ingredientsdb.query(
      'ingredientstable',
      where: 'recipeId IN (${List.filled(recipeIds.length, '?').join(',')})',
      whereArgs: recipeIds,
    );
    return ingredientRows;
  }
}
