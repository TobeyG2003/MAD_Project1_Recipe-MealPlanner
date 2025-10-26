import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseVersion = 2;

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
   
    
    recipesdb = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _onCreateRecipes(db, version);
        await _onCreateTags(db, version);
        await _onCreateRecipeTags(db, version);
        await _onCreateIngredients(db, version);
        await _onCreateInstructions(db, version);
        await _onCreateMeals(db, version);
      },
    );
    tagsdb = recipesdb;  
    recipetagsdb = recipesdb;
    ingredientsdb = recipesdb;
    instructionsdb = recipesdb;
    mealsdb = recipesdb;
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
  await db.insert('recipestable', {recipename: 'Oven-Roasted Chicken Shawarma', recipedescription: 'An oven roasted version of a great street food classic.', recipeimageUrl: 'assets/shawarma.jpg', recipefavorite: 0});
  await db.insert('recipestable', {recipename: 'Oyster Mushroom Fried Chicken', recipedescription: 'sample desc.', recipeimageUrl: 'assets/oyster.jpg', recipefavorite: 0});
  await db.insert('recipestable', {recipename: 'Good Old-Fashioned Pancakes', recipedescription: 'sample desc.', recipeimageUrl: 'assets/pancake.jpg', recipefavorite: 0});
  }
Future _onCreateTags(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'tagstable' (
$tagid INTEGER PRIMARY KEY,
$tagname TEXT
)
''');
await db.insert('tagstable', {tagname: 'Vegetarian', });
await db.insert('tagstable', {tagname: 'Vegan', });
await db.insert('tagstable', {tagname: 'Gluten-Free', });
await db.insert('tagstable', {tagname: 'Spicy', });

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
await db.insert('recipetagstable', {'recipeId': 1, 'tagId': 3,});
await db.insert('recipetagstable', {'recipeId': 2, 'tagId': 2,});
await db.insert('recipetagstable', {'recipeId': 3, 'tagId': 1,});
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
await db.insert('ingredientstable', {'name': 'Lemons', 'quantity': 1.25, 'unit': 'cup', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Olive Oil', 'quantity': .5, 'unit': 'cup', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Garlic cloves, peeled, mashed, and minced', 'quantity': 6.0, 'unit': '', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Kosher Salt', 'quantity': 1.0, 'unit': 'tsp', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Freshly ground black pepper', 'quantity': 2.0, 'unit': 'tsp', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Ground cumin', 'quantity': 2.0, 'unit': 'tsp', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Paprika', 'quantity': 2.0, 'unit': 'tsp', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Turmeric', 'quantity': 4.0, 'unit': 'ml', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Ground cinnamon', 'quantity': .25, 'unit': 'tsp', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Crushed red pepper', 'quantity': 1.0, 'unit': 'tsp', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Boneless, skinless chicken thighs', 'quantity': 2.0, 'unit': 'lbs', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Red onion', 'quantity': 1.0, 'unit': '', 'recipeId': 1,});
await db.insert('ingredientstable', {'name': 'Fresh parsley', 'quantity': 2.0, 'unit': 'tbsp', 'recipeId': 1,});

await db.insert('ingredientstable', {'name': 'Oyster mushrooms', 'quantity': 150.0, 'unit': 'grams', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'All purpose flour', 'quantity': 1.5, 'unit': 'cups', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Paprika', 'quantity': 1.5, 'unit': 'tsp', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Garlic Powder', 'quantity': 1.5, 'unit': 'tsp', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Onion Powder', 'quantity': 1.5, 'unit': 'tsp', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Turmeric', 'quantity': 1.0, 'unit': 'tsp', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Cayenne', 'quantity': .25, 'unit': 'tsp', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Salt', 'quantity': 1.0, 'unit': 'tsp', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Black pepper', 'quantity': 1.0, 'unit': 'tsp', 'recipeId': 2,});
await db.insert('ingredientstable', {'name': 'Oil for frying (I recommend Canola)', 'quantity': 4.0, 'unit': 'cups', 'recipeId': 2,});

await db.insert('ingredientstable', {'name': 'All-Purpose Flour', 'quantity': 3.0, 'unit': 'grams', 'recipeId': 3,});
await db.insert('ingredientstable', {'name': 'Baking Powder', 'quantity': 4.0, 'unit': 'ml', 'recipeId': 3,});
await db.insert('ingredientstable', {'name': 'White sugar/sweetener', 'quantity': 1.0, 'unit': 'tbsp', 'recipeId': 3,});
await db.insert('ingredientstable', {'name': 'Milk', 'quantity': 1.5, 'unit': 'cups', 'recipeId': 3,});
await db.insert('ingredientstable', {'name': 'Butter', 'quantity': 3.0, 'unit': 'tbsp', 'recipeId': 3,});
await db.insert('ingredientstable', {'name': 'Salt', 'quantity': .25, 'unit': 'tsp', 'recipeId': 3,});
await db.insert('ingredientstable', {'name': 'Egg', 'quantity': 2.0, 'unit': '', 'recipeId': 3,});

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
await db.insert('instructionstable', {'description': 'Prepare a marinade for the chicken. Combine the lemon juice, ½ cup olive oil, garlic, salt, pepper, cumin, paprika, turmeric, cinnamon and crushed red pepper in a large bowl, then whisk to combine. Add the chicken and toss well to coat. Cover and store in refrigerator for at least 1 hour and up to 12 hours.', 'stepNumber': 1, 'recipeId': 1,});
await db.insert('instructionstable', {'description': 'When ready to cook, heat oven to 425 degrees. Use the remaining tablespoon of olive oil to grease a rimmed sheet pan. Add the quartered onion to the chicken and marinade, and toss once to combine. Remove the chicken and onion from the marinade, and place on the pan, spreading everything evenly across it.', 'stepNumber': 2, 'recipeId': 1,});
await db.insert('instructionstable', {'description': 'Put the chicken in the oven and roast until it is browned, crisp at the edges and cooked through, about 30 to 40 minutes. Remove from the oven, allow to rest 2 minutes, then slice into bits. (To make the chicken even more crisp, set a large pan over high heat, add a tablespoon of olive oil to the pan, then the sliced chicken, and sauté until everything curls tight in the heat.)', 'stepNumber': 3, 'recipeId': 1,});
await db.insert('instructionstable', {'description': 'Scatter the parsley over the top and serve with tomatoes, cucumbers, pita, white sauce, hot sauce, olives, fried eggplant, feta, rice — really anything you desire.', 'stepNumber': 4, 'recipeId': 1,});

await db.insert('instructionstable', {'description': 'Wash and dry oyster mushrooms.', 'stepNumber': 1, 'recipeId': 2,});
await db.insert('instructionstable', {'description': 'In a large bowl, add the flour and all the spices. Mix together until well combined', 'stepNumber': 2, 'recipeId': 2,});
await db.insert('instructionstable', {'description': 'In a second bowl, add ⅓ cup of the flour mixture with ¾ cups of water. Whisk together until to achieve a smooth batter consistency.', 'stepNumber': 3, 'recipeId': 2,});
await db.insert('instructionstable', {'description': 'Dip each mushroom into the wet batter mixture then into the flour mixture. Double coat each mushroom back into the wet batter and then back in the flour mixture, making sure the mushrooms are fully coated in flour.', 'stepNumber': 4, 'recipeId': 2,});
await db.insert('instructionstable', {'description': 'Heat oil in a pot over high heat and carefully drop mushrooms into the oil one at a time in batches. Do not overcrowd the pot, you can fry a few at a time depending how large your pot is. Let them fry for a few minutes until nice and golden on all sides.', 'stepNumber': 5, 'recipeId': 2,});
await db.insert('instructionstable', {'description': 'Remove and place on paper towels to remove excess oil, then place on a cooling rack to keep crispy until the rest is done. Enjoy with your favourite dipping sauce!', 'stepNumber': 6, 'recipeId': 2,});

await db.insert('instructionstable', {'description': 'Gather all ingredients.', 'stepNumber': 1, 'recipeId': 3,});
await db.insert('instructionstable', {'description': 'Sift flour, baking powder, sugar, and salt together in a large bowl. Make a well in the center and add milk, melted butter, and egg; mix until smooth.', 'stepNumber': 2, 'recipeId': 3,});
await db.insert('instructionstable', {'description': 'Heat a lightly oiled griddle or pan over medium-high heat. Pour or scoop the batter onto the griddle, using approximately 1/4 cup for each pancake; cook until bubbles form and the edges are dry, about 2 to 3 minutes.', 'stepNumber': 3, 'recipeId': 3,});
await db.insert('instructionstable', {'description': 'Flip and cook until browned on the other side. Repeat with remaining batter.', 'stepNumber': 4, 'recipeId': 3,});
await db.insert('instructionstable', {'description': 'Serve and enjoy!', 'stepNumber': 5, 'recipeId': 3,});
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

    // Build base query for recipes
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

    // Build query with WHERE clause if we have conditions
    String query;
    if (conditions.isNotEmpty) {
      query = '''
        SELECT r.$recipeid, r.$recipename, r.$recipedescription, 
               r.$recipeimageUrl, r.$recipefavorite
        FROM recipestable r
        WHERE ${conditions.join(' AND ')}
      ''';
    } else {
      query = '''
        SELECT r.$recipeid, r.$recipename, r.$recipedescription, 
               r.$recipeimageUrl, r.$recipefavorite
        FROM recipestable r
      ''';
    }

    // Execute the query to get base recipe results
    List<Map<String, dynamic>> results = await recipesdb.rawQuery(query, whereArgs);

    // If tags are specified, filter by tags
    if (tags.isNotEmpty) {
      // Get tag IDs for the requested tag names
      final tagPlaceholders = List.filled(tags.length, '?').join(',');
      final List<Map<String, dynamic>> tagRows = await tagsdb.rawQuery(
        'SELECT $tagid FROM tagstable WHERE $tagname IN ($tagPlaceholders)',
        tags,
      );
      
      final Set<int> requestedTagIds = tagRows
          .map((row) => row[tagid] as int)
          .toSet();

      if (requestedTagIds.isEmpty) {
        return []; // No matching tags found
      }

      // Filter recipes that have ALL requested tags
      final List<Map<String, dynamic>> filteredResults = [];
      
      for (final recipe in results) {
        final recipeId = recipe[recipeid] as int;
        
        // Get all tags for this recipe
        final List<Map<String, dynamic>> recipeTagRows = await recipetagsdb.query(
          'recipetagstable',
          columns: [recipetagtagID],
          where: '$recipetagrecipeID = ?',
          whereArgs: [recipeId],
        );
        
        final Set<int> recipeTagIds = recipeTagRows
            .map((row) => row[recipetagtagID] as int)
            .toSet();
        
        // Check if recipe has all requested tags
        if (requestedTagIds.every((tagId) => recipeTagIds.contains(tagId))) {
          filteredResults.add(recipe);
        }
      }
      
      return filteredResults;
    }

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

  Future<int> clearMeal(int mealId) async {
    return await mealsdb.update(
      'mealstable',
      {
        mealrecipieID: null,
      },
      where: '$mealid = ?',
      whereArgs: [mealId],
    );
  }

  Future<List<Map<String,dynamic>>> getTagsForRecipe(int recipeId) async {
    // get tagIds from recipetagsdb
    final List<Map<String, dynamic>> tagIdRows = await recipetagsdb.query(
      'recipetagstable',
      columns: [recipetagtagID],
      where: '$recipetagrecipeID = ?',
      whereArgs: [recipeId],
    );

    if (tagIdRows.isEmpty) return [];

//turn into a list of unique ints
    final List<int> tagIds = tagIdRows
        .map((r) => r[recipetagtagID])
        .where((v) => v != null)
        .map((v) => v as int)
        .toSet()
        .toList();

    if (tagIds.isEmpty) return [];

    //query tagsdb for these tagIds
    final placeholders = List.filled(tagIds.length, '?').join(',');
    final List<Map<String, dynamic>> tagRows = await tagsdb.rawQuery(
      'SELECT $tagid, $tagname FROM tagstable WHERE $tagid IN ($placeholders)',
      tagIds,
    );
    
    return tagRows;
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

}