import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseVersion = 1;

  static const recipeid = 'id';
  static const recipename = 'name';
  static const recipedescription = 'description';
  static const recipeimageUrl = 'imageURl';

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

  late Database recipesdb;
  late Database tagsdb;
  late Database recipetagsdb;
  late Database ingredientsdb;
  late Database instructionsdb;

// this opens the database (and creates it if it doesn't exist)
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'myrecipes.db');
    final path2 = join(documentsDirectory.path, 'mytags.db');
    final path3 = join(documentsDirectory.path, 'myrecipetags.db');
    final path4 = join(documentsDirectory.path, 'myingredients.db');
    final path5 = join(documentsDirectory.path, 'myinstructions.db');
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
  }

// SQL code to create the database table
Future _onCreateRecipes(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'recipestable' (
$recipeid INTEGER PRIMARY KEY,
$recipename TEXT,
$recipedescription TEXT,
$recipeimageUrl TEXT
)
''');
await db.insert('recipesstable', {'name': 'sample1', 'description': 'sample desc.', 'imageURL': 'sample.jpg', });
await db.insert('recipesstable', {'name': 'sample2', 'description': 'sample desc.', 'imageURL': 'sample.jpg', });
await db.insert('recipesstable', {'name': 'sample3', 'description': 'sample desc.', 'imageURL': 'sample.jpg', });
  }
Future _onCreateTags(Database db, int version) async {
    await db.execute('''
CREATE TABLE 'tagstable' (
$tagid INTEGER PRIMARY KEY,
$tagname TEXT,
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
PRIMARY KEY ($recipetagrecipeID, $recipetagtagID)
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
  /*Future<int> insertcard(Map<String, dynamic> row) async {
    return await cardsdb.insert('cardstable', row);
  }
  Future<int> updatecard(Map<String, dynamic> row) async {
    int id = row[cardid];
    return await cardsdb.update(
      'cardstable',
      row,
      where: '$cardid = ?',
      whereArgs: [id],
    );
  }
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