import 'package:flutter/material.dart';
import 'database_setup.dart';
import 'dart:async';
import 'screens/recipe_details.dart';
import 'screens/planner_screens.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

final dbHelper = DatabaseHelper();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Recipe & Meal Planner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  int? selectedRecipeId; // for when a recipe is selected, it knows what id to pull up in the recipes tab
  List<String> selectedTags = []; // list of currently selected tags for filtering
  List<Map<String, dynamic>> availableTags = []; // all available tags from database
  String searchText = ''; // current search text
  // Initialize with an empty list future so build can run before DB init completes.
  Future<List<Map<String, dynamic>>> recipesList = Future.value([]);
  Future<List<Map<String, dynamic>>> favoritesList = Future.value([]);
  Future<List<Map<String, dynamic>>> groceryList = Future.value([]);
  Set<int> _obtainedGroceryItems = {}; // Track which grocery items are checked

  // Share tab form controllers
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _recipeDescriptionController = TextEditingController();
  String? imagestring;
  bool _isFavorite = false;
  
  // Ingredients list - each ingredient has name, quantity, and unit
  List<Map<String, TextEditingController>> _ingredients = [
    {
      'name': TextEditingController(),
      'quantity': TextEditingController(),
      'unit': TextEditingController(),
    }
  ];
  
  // Instructions list - each instruction has a description
  List<TextEditingController> _instructions = [TextEditingController()];
  
  // Selected tags for the new recipe
  List<String> _selectedRecipeTags = [];

      @override
      void initState() {
        super.initState();
        _tabController = TabController(length: 5, vsync: this);
        _tabController.animation!.addListener(() {
        setState(() {
          
        });
      });
        // Add listener to refresh grocery list when switching to that tab
        _tabController.addListener(() {
          if (_tabController.index == 4) { // Grocery list is tab index 4
            setState(() {
              groceryList = dbHelper.getGrocerylistfromallMeals();
            });
          }
        });
        
        // Initialize the database helper and load initial recipes
        dbHelper.init().then((_) async {
          recipesList = dbHelper.queryItemsWithFilters('', []);
          favoritesList = dbHelper.queryItemsWithFilters('', [], onlyFavorites: true);
          groceryList = dbHelper.getGrocerylistfromallMeals();
          availableTags = await dbHelper.getAllTags();
          setState(() {});
        });
        
      }

      @override
      void dispose() {
        _tabController.dispose();
        _recipeNameController.dispose();
        _recipeDescriptionController.dispose();
        
        // Dispose ingredient controllers
        for (var ingredient in _ingredients) {
          ingredient['name']?.dispose();
          ingredient['quantity']?.dispose();
          ingredient['unit']?.dispose();
        }
        
        // Dispose instruction controllers
        for (var instruction in _instructions) {
          instruction.dispose();
        }
        
        super.dispose();
      }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 188, 44, 44),
        title: Text(widget.title),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 188, 44, 44),
        currentIndex: _tabController.index,
        onTap: (index) {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_calendar), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Groceries'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New'),
        ],
      ),
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          const double speedFactor = 100.0;
          final animation = _tabController.animation;
          final double screenW = constraints.maxWidth;
          const int repeatCount = 3;
          final double wideWidth = screenW * repeatCount;

          return Stack(
            children: [
              AnimatedBuilder(
                animation: animation ?? AlwaysStoppedAnimation(0),
                builder: (context, child) {
                  final double animValue = (animation?.value ?? _tabController.index).toDouble();
                  final double rawDx = animValue * speedFactor;
                  final double dx = -(rawDx % screenW);
                  return Positioned(
                    left: dx,
                    top: 0,
                    bottom: 0,
                    child: child!,
                  );
                },
                child: Container(
                  width: wideWidth,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                      image: AssetImage('assets/tiledbackground.jpg'),
                      scale: 1.25,
                      colorFilter: ColorFilter.mode(
                       Colors.black.withOpacity(.8), // Adjust opacity here
                        BlendMode.dstATop, // Or other BlendMode for different effects
                      ),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    //tab 1 recipes
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      SizedBox(height: 25),
                          Container(
                            width: 400,
                            height: 75,
                            alignment: Alignment.center,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                        color: const Color.fromARGB(240, 255, 255, 255),
                        border: Border.all(
                          color: const Color.fromARGB(255, 186, 28, 28),
                          width: 2.0,
                          ),
                        borderRadius: BorderRadius.circular(8.0),
                        ),
                          child: Text('Find Your Recipe',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                      ),
                      SizedBox(height: 20),
                      Row (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 275,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromARGB(255, 186, 28, 28),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search recipes...',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                border: InputBorder.none,
                              ),
                              onChanged: (text) {
                                setState(() {
                                  searchText = text;
                                  recipesList = dbHelper.queryItemsWithFilters(text, selectedTags);
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _showTagFilterDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 188, 44, 44),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_list, size: 18, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Filter', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 500,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: recipesList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            final data = snapshot.data ?? [];
                            if (data.isEmpty) {
                              return const Center(child: Text('No recipes found'));
                            }
                            return GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: .9,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                for (var i = 0; i < data.length; i++)
                                  generateCard(
                                    recipeId: (data[i]['id'] ?? 0) as int,
                                    name: (data[i]['name'] ?? '').toString(),
                                
                                    recipeimageUrl: (data[i]['imageURl'] ?? '').toString(),
                                    index: i,
                                  )
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
                      ),
                    ),
                    //tab 2 planner
                    MealPlannerScreen(
                      onGroceryListGenerated: () {
                        setState(() {
                          groceryList = dbHelper.getGrocerylistfromallMeals();
                        });
                      },
                    ),
                    //tab 3 favorites, basically same stuff as recipes
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      SizedBox(height: 25),
                          Container(
                            width: 400,
                            height: 75,
                            alignment: Alignment.center,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                        color: const Color.fromARGB(240, 255, 255, 255),
                        border: Border.all(
                          color: const Color.fromARGB(255, 186, 28, 28),
                          width: 2.0,
                          ),
                        borderRadius: BorderRadius.circular(8.0),
                        ),
                          child: Text('Your Favorites',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                      ),
                      SizedBox(height: 20),
                      Row (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 275,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromARGB(255, 186, 28, 28),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search favorites...',
                                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                border: InputBorder.none,
                              ),
                              onChanged: (text) {
                                setState(() {
                                  searchText = text;
                                  favoritesList = dbHelper.queryItemsWithFilters(text, selectedTags, onlyFavorites: true);
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              _showTagFilterDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 188, 44, 44),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.filter_list, size: 18, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Filter', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 500,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: favoritesList,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            final data = snapshot.data ?? [];
                            if (data.isEmpty) {
                              return const Center(child: Text('No recipes found'));
                            }
                            return GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.8,
                              shrinkWrap: true,
                              children: [
                                for (var i = 0; i < data.length; i++)
                                  generateCard(
                                    recipeId: (data[i]['id'] ?? 0) as int,
                                    name: (data[i]['name'] ?? '').toString(),
                                    recipeimageUrl: (data[i]['imageURl'] ?? '').toString(),
                                    index: i,
                                  )
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
                    ),
                    //tab 4 grocery list
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      SizedBox(height: 25),
                          Container(
                            width: 400,
                            height: 75,
                            alignment: Alignment.center,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                        color: const Color.fromARGB(240, 255, 255, 255),
                        border: Border.all(
                          color: const Color.fromARGB(255, 186, 28, 28),
                          width: 2.0,
                          ),
                        borderRadius: BorderRadius.circular(8.0),
                        ),
                          child: Text('Grocery List',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                      ),
                      SizedBox(height: 20),
                      Container(
                            width: 400,
                            alignment: Alignment.center,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                        color: const Color.fromARGB(240, 255, 255, 255),
                        border: Border.all(
                          color: const Color.fromARGB(255, 186, 28, 28),
                          width: 2.0,
                          ),
                        borderRadius: BorderRadius.circular(8.0),
                        ),
                          child: Column(
                            children: [
                              Text('Based on your Meal Planner:',
                                style: TextStyle(
                              fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 10),
                              StatefulBuilder(
                                builder: (context, setGroceryState) {
                                  return FutureBuilder<List<Map<String, dynamic>>>(
                                    future: groceryList,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return Center(child: Text('Error: ${snapshot.error}'));
                                      }
                                      final data = snapshot.data ?? [];
                                      if (data.isEmpty) {
                                        return const Center(child: Text('No ingredients found', style: TextStyle(fontSize: 18),));
                                      }
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: data.length,
                                        itemBuilder: (context, index) {
                                          final item = data[index];
                                          final obtained = _obtainedGroceryItems.contains(index);
                                          final displayText = '${item['ingredient_name']} - ${item['total_quantity']} ${item['unit']}';
                                          return CheckboxListTile(
                                            value: obtained,
                                            onChanged: (checked) {
                                              setGroceryState(() {
                                                if (checked == true) {
                                                  _obtainedGroceryItems.add(index);
                                                } else {
                                                  _obtainedGroceryItems.remove(index);
                                                }
                                              });
                                            },
                                            title: Text(
                                              displayText,
                                              style: TextStyle(
                                                fontSize: 18,
                                                decoration: obtained ? TextDecoration.lineThrough : null,
                                                color: obtained ? Colors.grey : Colors.black,
                                              ),
                                            ),
                                            controlAffinity: ListTileControlAffinity.leading,
                                            activeColor: const Color.fromARGB(255, 188, 44, 44),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                      ),
                      ],
                      ),
                    ),
                    //tab 5 add new screen with complete recipe form
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 25),
                            Container(
                              width: 400,
                              height: 75,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(240, 255, 255, 255),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 186, 28, 28),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                'Add a New Recipe',
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              width: 400,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(240, 255, 255, 255),
                                border: Border.all(
                                  color: const Color.fromARGB(255, 186, 28, 28),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Recipe Name Field
                                  Text(
                                    'Recipe Name',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: _recipeNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter recipe name...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(255, 186, 28, 28),
                                          width: 2.0,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 10.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Recipe Description Field
                                  Text(
                                    'Recipe Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: _recipeDescriptionController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                      hintText: 'Enter recipe description...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(255, 186, 28, 28),
                                          width: 2.0,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 10.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Image Upload Section
                                  Text(
                                    'Recipe Image',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Center(
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final ImagePicker picker = ImagePicker();
                                            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                            if (image != null) {
                                              final Uint8List bytes = await image.readAsBytes();
                                              setState(() {
                                                imagestring = 'base64,${base64Encode(bytes)}';
                                              });
                                              print('Selected image path: ${image.path}');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color.fromARGB(255, 188, 44, 44),
                                          ),
                                          child: Text(
                                            'Select Image',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        if (imagestring != null) ...[
                                          SizedBox(height: 10),
                                          Text(
                                            'Image selected',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: const Color.fromARGB(255, 181, 26, 26),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.memory(
                                              base64Decode(imagestring!.substring('base64,'.length)),
                                              height: 150,
                                              width: 200,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Ingredients Section
                                  Text(
                                    'Ingredients',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ..._ingredients.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var ingredient = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: TextField(
                                              controller: ingredient['name'],
                                              decoration: InputDecoration(
                                                hintText: 'Name',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 8.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: TextField(
                                              controller: ingredient['quantity'],
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              decoration: InputDecoration(
                                                hintText: 'Qty',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 8.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            flex: 2,
                                            child: TextField(
                                              controller: ingredient['unit'],
                                              decoration: InputDecoration(
                                                hintText: 'Unit',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                  vertical: 8.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              if (_ingredients.length > 1) {
                                                setState(() {
                                                  ingredient['name']?.dispose();
                                                  ingredient['quantity']?.dispose();
                                                  ingredient['unit']?.dispose();
                                                  _ingredients.removeAt(index);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _ingredients.add({
                                          'name': TextEditingController(),
                                          'quantity': TextEditingController(),
                                          'unit': TextEditingController(),
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.add_circle, color: const Color.fromARGB(255, 188, 44, 44)),
                                    label: Text(
                                      'Add Ingredient',
                                      style: TextStyle(color: const Color.fromARGB(255, 188, 44, 44)),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Instructions Section
                                  Text(
                                    'Instructions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ..._instructions.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var instruction = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                                            child: Text(
                                              '${index + 1}.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: instruction,
                                              maxLines: 2,
                                              decoration: InputDecoration(
                                                hintText: 'Enter step description...',
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 10.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              if (_instructions.length > 1) {
                                                setState(() {
                                                  instruction.dispose();
                                                  _instructions.removeAt(index);
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _instructions.add(TextEditingController());
                                      });
                                    },
                                    icon: Icon(Icons.add_circle, color: const Color.fromARGB(255, 188, 44, 44)),
                                    label: Text(
                                      'Add Instruction Step',
                                      style: TextStyle(color: const Color.fromARGB(255, 188, 44, 44)),
                                    ),
                                  ),
                                  SizedBox(height: 20),

                                  // Tags Section
                                  Text(
                                    'Tags',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: availableTags.map((tag) {
                                      final tagName = tag['name'] as String;
                                      final isSelected = _selectedRecipeTags.contains(tagName);
                                      return FilterChip(
                                        label: Text(tagName),
                                        selected: isSelected,
                                        selectedColor: const Color.fromARGB(255, 230, 200, 200),
                                        checkmarkColor: const Color.fromARGB(255, 188, 44, 44),
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedRecipeTags.add(tagName);
                                            } else {
                                              _selectedRecipeTags.remove(tagName);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                  if (availableTags.isEmpty)
                                    Text(
                                      'No tags available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  SizedBox(height: 20),

                                  // Favorite Checkbox
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _isFavorite,
                                        activeColor: const Color.fromARGB(255, 188, 44, 44),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _isFavorite = value ?? false;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Mark as Favorite',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),

                                  // Submit Button
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // Validate inputs
                                        if (_recipeNameController.text.trim().isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Please enter a recipe name'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        if (_recipeDescriptionController.text.trim().isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Please enter a recipe description'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }

                                        //Insert recipe into database and get the new recipe ID
                                        //Insert recipe into database and get the new recipe ID
                                        try {
                                          //Insert recipe and get the new ID
                                          //Insert recipe and get the new ID
                                          final int newRecipeId = await dbHelper.recipesdb.insert('recipestable', {
                                            'name': _recipeNameController.text.trim(),
                                            'description': _recipeDescriptionController.text.trim(),
                                            'imageURl': imagestring ?? '',
                                            'isFavorite': _isFavorite ? 1 : 0,
                                          });

                                          //Insert ingredients with recipe foreign key
                                          //Insert ingredients with recipe foreign key
                                          for (var ingredient in _ingredients) {
                                            final name = ingredient['name']!.text.trim();
                                            final quantityText = ingredient['quantity']!.text.trim();
                                            final unit = ingredient['unit']!.text.trim();
                                            
                                            if (name.isNotEmpty) {
                                              final double quantity = double.tryParse(quantityText) ?? 0.0;
                                              await dbHelper.ingredientsdb.insert('ingredientstable', {
                                                'name': name,
                                                'quantity': quantity,
                                                'unit': unit,
                                                'recipeId': newRecipeId,
                                              });
                                            }
                                          }

                                          //Insert instructions with recipe foreign key
                                          //Insert instructions with recipe foreign key
                                          for (int i = 0; i < _instructions.length; i++) {
                                            final description = _instructions[i].text.trim();
                                            if (description.isNotEmpty) {
                                              await dbHelper.instructionsdb.insert('instructionstable', {
                                                'description': description,
                                                'stepNumber': i + 1,
                                                'recipeId': newRecipeId,
                                              });
                                            }
                                          }

                                          //Insert recipe-tag associations with foreign keys
                                          //Insert recipe-tag associations with foreign keys
                                          for (var tagName in _selectedRecipeTags) {
                                            //Find the tag ID from availableTags
                                            //Find the tag ID from availableTags
                                            final tagData = availableTags.firstWhere(
                                              (tag) => tag['name'] == tagName,
                                              orElse: () => <String, dynamic>{},
                                            );
                                            
                                            if (tagData.isNotEmpty) {
                                              final tagId = tagData['id'] as int;
                                              await dbHelper.recipetagsdb.insert('recipetagstable', {
                                                'recipeId': newRecipeId,
                                                'tagId': tagId,
                                              });
                                            }
                                          }

                                          //Show success message
                                          //Show success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Recipe added successfully!'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );

                                          //Clear form
                                          //Clear form
                                          _recipeNameController.clear();
                                          _recipeDescriptionController.clear();
                                          
                                          //Clear and reset ingredients
                                          //Clear and reset ingredients
                                          for (var ingredient in _ingredients) {
                                            ingredient['name']?.dispose();
                                            ingredient['quantity']?.dispose();
                                            ingredient['unit']?.dispose();
                                          }
                                          
                                          //Clear and reset instructions
                                          //Clear and reset instructions
                                          for (var instruction in _instructions) {
                                            instruction.dispose();
                                          }
                                          
                                          setState(() {
                                            imagestring = null;
                                            _isFavorite = false;
                                            _selectedRecipeTags.clear();
                                            
                                            //Reset to single empty fields
                                            _ingredients = [
                                              {
                                                'name': TextEditingController(),
                                                'quantity': TextEditingController(),
                                                'unit': TextEditingController(),
                                              }
                                            ];
                                            _instructions = [TextEditingController()];
                                          });

                                          //Refresh recipes list
                                          //Refresh recipes list
                                          recipesList = dbHelper.queryItemsWithFilters('', []);
                                          favoritesList = dbHelper.queryItemsWithFilters('', [], onlyFavorites: true);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error adding recipe: $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 188, 44, 44),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 40.0,
                                          vertical: 15.0,
                                        ),
                                      ),
                                      child: Text(
                                        'Submit Recipe',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showTagFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter by Tags'),
                  if (selectedTags.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedTags.clear();
                        });
                        setState(() {
                          recipesList = dbHelper.queryItemsWithFilters(searchText, selectedTags);
                        });
                      },
                      child: Text('Clear All'),
                    ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: availableTags.isEmpty
                    ? Center(child: Text('No tags available'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableTags.length,
                        itemBuilder: (context, index) {
                          final tag = availableTags[index];
                          final tagName = tag['name'] as String;
                          final isSelected = selectedTags.contains(tagName);

                          return CheckboxListTile(
                            title: Text(tagName),
                            value: isSelected,
                            activeColor: const Color.fromARGB(255, 188, 44, 44),
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  selectedTags.add(tagName);
                                } else {
                                  selectedTags.remove(tagName);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      recipesList = dbHelper.queryItemsWithFilters(searchText, selectedTags);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 188, 44, 44),
                  ),
                  child: Text('Apply Filters', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class generateCard extends StatefulWidget {
  final int recipeId;
  final String name;
  final String recipeimageUrl;
  final int index;

  const generateCard({
    super.key, 
    required this.recipeId, 
    required this.name, 
    required this.recipeimageUrl,
    this.index = 0,
  });

  @override
  State<generateCard> createState() => _GenerateCardState();
}

class _GenerateCardState extends State<generateCard> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _tagsFuture;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  final Duration duration = const Duration(milliseconds: 600);
  final Duration baseDelay = const Duration(milliseconds: 100);
  final int staggerDelayMs = 80; // Delay between each card
  final double offset = 30.0;


  @override
  void initState() {
    super.initState();
    _tagsFuture = dbHelper.getTagsForRecipe(widget.recipeId);
    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, offset / 100),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Calculate staggered delay based on index
    final delay = baseDelay + Duration(milliseconds: widget.index * staggerDelayMs);
    
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(recipeId: widget.recipeId),
        ),
      );

      if (result == 2) {
        // Meal plan update later
      } else {
        // refresh favorites
        final homeState = context.findAncestorStateOfType<_MyHomePageState>();
        homeState?.setState(() {
          homeState.favoritesList =
              dbHelper.queryItemsWithFilters('', [], onlyFavorites: true);
        });
  }
},

      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: EdgeInsets.all(8.0),
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color.fromARGB(255, 186, 28, 28),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: widget.recipeimageUrl.isEmpty
                      ? Container(
                          width: 150,
                          height: 120,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported),
                        )
                      : widget.recipeimageUrl.startsWith('base64,') ?
                          Image.memory(
                            base64Decode(widget.recipeimageUrl.substring('base64,'.length)),
                            height: 120,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                      :Image.asset(
                          widget.recipeimageUrl,
                          width: 150,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _tagsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    final tagList = snapshot.data ?? [];
                    if (tagList.isEmpty) return const SizedBox.shrink();
                    return Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (var tag in tagList)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 230, 200, 200),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              tag['name'] ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color.fromARGB(255, 255, 52, 52),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}