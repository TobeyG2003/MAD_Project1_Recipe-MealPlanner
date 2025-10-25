import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseVersion = 1;

  static const recipeid = 'id';
  static const recipename = 'name';
  static const recipedescription = 'description';
  static const recipeimageUrl = 'imageURl';
  static const recipefavorite = 'isFavorite';

  static const tagid = 'id';
  static const tagname = 'name';

  static const recipetagrecipeID = 'recipeId';
  static const recipetagtagID = 'tagId';

  static const ingredientid = 'id';
  static const ingredientname = 'name';
  static const ingredientquantity = 'quantity';
  static const ingredientunit = 'unit';
  static const ingredientrecipeID = 'recipeId';

  static const instructionid = 'id';
  static const instructionstepNumber = 'stepNumber';
  static const instructiondescription = 'description';
  static const instructionrecipeID = 'recipeId';

  static const mealid = 'id';
  static const mealrecipieID = 'recipeId';
  static const mealdate = 'date';

  late Database recipesdb;
  late Database tagsdb;
  late Database recipetagsdb;
  late Database ingredientsdb;
  late Database instructionsdb;
  late Database mealsdb;

// this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'myrecipes.db');
    final path2 = join(documentsDirectory.path, 'mytags.db');
    final path3 = join(documentsDirectory.path, 'myrecipetags.db');
    final path4 = join(documentsDirectory.path, 'myingredients.db');
    final path5 = join(documentsDirectory.path, 'myinstructions.db');
    final path6 = join(documentsDirectory.path, 'mymeals.db');
    recipesdb = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreateRecipes,
    );
    tagsdb = await openDatabase(
      path2,
      version: _databaseVersion,
      onCreate: _onCreateTags,
    );
    recipetagsdb = await openDatabase(
      path3,
      version: _databaseVersion,
      onCreate: _onCreateRecipeTags,
    );
    ingredientsdb = await openDatabase(
      path4,
      version: _databaseVersion,
      onCreate: _onCreateIngredients,
    );
    instructionsdb = await openDatabase(
      path5,
      version: _databaseVersion,
      onCreate: _onCreateInstructions,
    );
    mealsdb = await openDatabase(
      path6,
      version: _databaseVersion,
      onCreate: _onCreateMeals,
    );
  }

// SQL code to create the database table
Future _onCreateRecipes(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'recipestable' (
$recipeid INTEGER PRIMARY KEY,
$recipename TEXT,
$recipedescription TEXT,
$recipeimageUrl TEXT,
$recipefavorite INTEGER DEFAULT 0
)
''');
  // Use the column constants to avoid mismatched keys
  await db.insert('recipestable', {recipename: 'sample1', recipedescription: 'sample desc.', recipeimageUrl: 'assets/sample1.jpg', recipefavorite: 0});
  await db.insert('recipestable', {recipename: 'sample2', recipedescription: 'sample desc.', recipeimageUrl: 'assets/sample2.jpg', recipefavorite: 0});
  await db.insert('recipestable', {recipename: 'sample3', recipedescription: 'sample desc.', recipeimageUrl: 'assets/sample3.jpg', recipefavorite: 0});
  }
Future _onCreateTags(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'tagstable' (
$tagid INTEGER PRIMARY KEY,
$tagname TEXT
)
''');
await db.insert('tagstable', {'name': 'Vegetarian', });
await db.insert('tagstable', {'name': 'Vegan', });
await db.insert('tagstable', {'name': 'Gluten-Free', });
await db.insert('tagstable', {'name': 'Spicy', });

  }
  Future _onCreateRecipeTags(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'recipetagstable' (
$recipetagrecipeID INTEGER NOT NULL,
$recipetagtagID INTEGER NOT NULL,
PRIMARY KEY ($recipetagrecipeID, $recipetagtagID),
FOREIGN KEY ($recipetagrecipeID) REFERENCES recipestable($recipeid) ON DELETE CASCADE,
FOREIGN KEY ($recipetagtagID) REFERENCES tagstable($tagid) ON DELETE CASCADE
)
''');
await db.insert('recipetagstable', {'recipeId': 1, 'tagId': 1,});
await db.insert('recipetagstable', {'recipeId': 2, 'tagId': 2,});
await db.insert('recipetagstable', {'recipeId': 3, 'tagId': 3,});
  }
Future _onCreateIngredients(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'ingredientstable' (
$ingredientid INTEGER PRIMARY KEY,
$ingredientname TEXT,
$ingredientquantity REAL,
$ingredientunit TEXT,
$ingredientrecipeID INTEGER,
FOREIGN KEY ($ingredientrecipeID) REFERENCES recipestable($recipeid) ON DELETE CASCADE
)
''');
await db.insert('ingredientstable', {'name': 'Ingredient1', 'quantity': 1.0, 'unit': 'cup', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Ingredient2', 'quantity': 2.0, 'unit': 'tbsp', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Ingredient3', 'quantity': 3.0, 'unit': 'grams', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Ingredient4', 'quantity': 4.0, 'unit': 'ml', 'recipeId': 3,});
  }
Future _onCreateInstructions(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'instructionstable' (
$instructionid INTEGER PRIMARY KEY,
$instructiondescription TEXT,
$instructionstepNumber INTEGER,
$instructionrecipeID INTEGER,
FOREIGN KEY ($instructionrecipeID) REFERENCES recipestable($recipeid) ON DELETE CASCADE
)
''');
await db.insert('instructionstable', {'description': 'Step 1 description', 'stepNumber': 1, 'recipeId': 1,});
await db.insert('instructionstable', {'description': 'Step 2 description', 'stepNumber': 2, 'recipeId': 1,});
await db.insert('instructionstable', {'description': 'Step 1 description', 'stepNumber': 1, 'recipeId': 2,});
await db.insert('instructionstable', {'description': 'Step 1 description', 'stepNumber': 1, 'recipeId': 3,});
  }
Future _onCreateMeals(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'mealstable' (
$mealid INTEGER PRIMARY KEY,
$mealrecipieID INTEGER,
$mealdate TEXT,
FOREIGN KEY ($mealrecipieID) REFERENCES recipestable($recipeid) ON DELETE CASCADE
)
''');
await db.insert('mealstable', {'recipeId': null, 'date': 'Sunday',});
await db.insert('mealstable', {'recipeId': null, 'date': 'Monday',});
await db.insert('mealstable', {'recipeId': null, 'date': 'Tuesday',});
await db.insert('mealstable', {'recipeId': null, 'date': 'Wednesday',});
await db.insert('mealstable', {'recipeId': null, 'date': 'Thursday',});
await db.insert('mealstable', {'recipeId': null, 'date': 'Friday',});
await db.insert('mealstable', {'recipeId': null, 'date': 'Saturday',});
  }
  
  /*Future<int> insertcard(Map<String, dynamic> row) async {
    return await cardsdb.insert('cardstable', row);
  }*/

  Future<bool> getFavoriteStatus(int id) async {
    final List<Map<String, dynamic>> result = await recipesdb.query(
      'recipestable',
      columns: [recipefavorite],
      where: '$recipeid = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first[recipefavorite] == 1;
    }
    return false;
  }

  Future<int> toggleFavorite(int id) async {
    bool currentStatus = await getFavoriteStatus(id);
    return await recipesdb.update(
      'recipestable',
      {
        recipefavorite: currentStatus ? 1 : 0,
      },
      where: '$recipeid = ?',
      whereArgs: [id],
    );
  }

  /*Future<List<Map<String, dynamic>>> getFavoriteRecipes() async {
    return await recipesdb.query(
      'recipestable',
      where: '$recipefavorite = ?',
      whereArgs: [1],
    );
  }*/

  Future<List<Map<String, dynamic>>> queryItemsWithFilters(String nameSearch, List<String> tags, {bool? onlyFavorites}) async {
    // Build the base query
    String query = '''
      SELECT DISTINCT r.$recipeid, r.$recipename, r.$recipedescription, 
                     r.$recipeimageUrl, r.$recipefavorite
      FROM recipestable r
    ''';

    List<dynamic> whereArgs = [];
    List<String> conditions = [];

    // Add name search condition if provided
    if (nameSearch.isNotEmpty) {
      conditions.add('r.$recipename LIKE ?');
      whereArgs.add('%$nameSearch%');
    }

    // Add favorites filter if requested
    if (onlyFavorites == true) {
      conditions.add('r.$recipefavorite = 1');
    }

    // Add tag filtering if tags are provided
    if (tags.isNotEmpty) {
      // Join with recipe_tags and tags tables
      query += '''
        INNER JOIN recipetagstable rt ON r.$recipeid = rt.$recipetagrecipeID
        INNER JOIN tagstable t ON rt.$recipetagtagID = t.$tagid
      ''';
      
      // Add tag condition
      final tagPlaceholders = List.filled(tags.length, '?').join(',');
      conditions.add('t.$tagname IN ($tagPlaceholders)');
      whereArgs.addAll(tags);

      // Group by recipe ID to ensure we don't get duplicates
      query += '\nGROUP BY r.$recipeid';
      
      // If multiple tags are provided, ensure all tags are matched
      if (tags.length > 1) {
        query += '\nHAVING COUNT(DISTINCT t.$tagid) = ${tags.length}';
      }
    }

    // Add WHERE clause if we have conditions
    if (conditions.isNotEmpty) {
      query += '\nWHERE ' + conditions.join(' AND ');
    }

    // Execute the query
    final List<Map<String, dynamic>> results = await recipesdb.rawQuery(query, whereArgs);
    return results;
  }

  Future <List<Map<String, dynamic>>> getAllTags() async {
    return await tagsdb.query('tagstable');
  }
  Future<int> updateMeal(int mealId, int? recipeId) async {
    return await mealsdb.update(
      'mealstable',
      {
        mealrecipieID: recipeId,
      },
      where: '$mealid = ?',
      whereArgs: [mealId],
    );
  }
  Future<List<Map<String,dynamic>>> getRecipebyID(int recipeId) async {
    return await recipesdb.query(
      'recipestable',
      where: '$recipeid = ?',
      whereArgs: [recipeId],
    );
  }

  Future<List<Map<String, dynamic>>> getRecipesfromMeals() async {
    return await mealsdb.rawQuery('''
      SELECT m.$mealid, m.$mealdate, r.$recipeid, r.$recipename, r.$recipeimageUrl
      FROM mealstable m
      LEFT JOIN recipestable r ON m.$mealrecipieID = r.$recipeid
      ORDER BY 
        CASE m.$mealdate
          WHEN 'Sunday' THEN 1
          WHEN 'Monday' THEN 2
          WHEN 'Tuesday' THEN 3
          WHEN 'Wednesday' THEN 4
          WHEN 'Thursday' THEN 5
          WHEN 'Friday' THEN 6
          WHEN 'Saturday' THEN 7
        END
    ''');
  }
  Future<List<Map<String, dynamic>>> getInstructionsforRecipe(int recipeId) async {
    return await instructionsdb.query(
      'instructionstable',
      where: '$instructionrecipeID = ?',
      whereArgs: [recipeId],
      orderBy: '$instructionstepNumber ASC',
    );
  }
  Future<List<Map<String, dynamic>>> getIngredientsforRecipe(int recipeId) async {
    return await ingredientsdb.query(
      'ingredientstable',
      where: '$ingredientrecipeID = ?',
      whereArgs: [recipeId],
    );
  }
  Future<List<Map<String, dynamic>>> getGrocerylistfromallMeals() async {
    // Note: ingredients are stored in `ingredientsdb` while meals are stored in `mealsdb`.
    // You cannot JOIN tables across separate sqlite database connections. Instead,
    // fetch the planned meals from the meals database, then load ingredients from
    // the ingredients database and aggregate quantities in Dart.

    final List<Map<String, dynamic>> meals = await mealsdb.query(
      'mealstable',
      columns: [mealrecipieID],
    );

    if (meals.isEmpty) return [];

    // Map key = '$name|$unit' -> { 'name': name, 'unit': unit, 'quantity': double }
    final Map<String, Map<String, dynamic>> totals = {};

    for (final meal in meals) {
      final recipeId = meal[mealrecipieID];
      if (recipeId == null) continue;

      final List<Map<String, dynamic>> ingredients = await ingredientsdb.query(
        'ingredientstable',
        where: '$ingredientrecipeID = ?',
        whereArgs: [recipeId],
      );

        for (final ing in ingredients) {
          final String name = (ing[ingredientname] ?? '').toString();
          final String unit = (ing[ingredientunit] ?? '').toString();
          final dynamic rawQty = ing[ingredientquantity] ?? 0;
          final double qty = rawQty is num
              ? rawQty.toDouble()
              : double.tryParse(rawQty.toString()) ?? 0.0;

          final key = '$name|$unit';
          if (!totals.containsKey(key)) {
            totals[key] = {'name': name, 'unit': unit, 'quantity': 0.0};
          }
          totals[key]!['quantity'] = (totals[key]!['quantity'] as double) + qty;
      }
    }

    // Convert to the expected list format
    final List<Map<String, dynamic>> result = totals.values.map((entry) {
      return {
        ingredientname: entry['name'],
        'totalQuantity': entry['quantity'],
        ingredientunit: entry['unit'],
      };
    }).toList();

    return result;
  }



  
  /*
  Future<int> delete(int id) async {
    return await cardsdb.delete(
      'cardstable',
      where: '$cardfolderID = ?',
      whereArgs: [id],
    );
  }

  Future<String> getcardimage(int id) async {
    final result = await cardsdb.query(
      'cardstable',
      columns: [cardimageUrl],
      where: '$cardid = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty && result[0][cardimageUrl] != null) {
      return result[0][cardimageUrl] as String;
    }
    return '';
  }*/
}