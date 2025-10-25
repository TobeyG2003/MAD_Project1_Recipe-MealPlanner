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
await db.insert('recipestable', {'name': 'sample1', 'description': 'sample desc.', 'imageURL': 'sample.jpg', 'favorite': 0, });
await db.insert('recipestable', {'name': 'sample2', 'description': 'sample desc.', 'imageURL': 'sample.jpg', 'favorite': 0, });
await db.insert('recipestable', {'name': 'sample3', 'description': 'sample desc.', 'imageURL': 'sample.jpg', 'favorite': 0, });
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

  Future<List<Map<String, dynamic>>> getFavoriteRecipes() async {
    return await recipesdb.query(
      'recipestable',
      where: '$recipefavorite = ?',
      whereArgs: [1],
    );
  }

  Future<List<Map<String, dynamic>>> queryItemsWithFilters(String nameSearch, List<String> tags) async {
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