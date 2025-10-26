import 'package:flutter/material.dart';
import 'database_setup.dart';
import 'dart:async';
import 'screens/recipe_details.dart';
import 'screens/planner_screens.dart';

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

      @override
      void initState() {
        super.initState();
        _tabController = TabController(length: 5, vsync: this);
        _tabController.animation!.addListener(() {
        setState(() {
          
        });
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
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Recipe'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_calendar), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Grocery List'),
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
                              //childAspectRatio: 1.0,
                              shrinkWrap: true,
                              children: [
                                for (var i = 0; i < data.length; i++)
                                  generateCard(
                                    recipeId: data[i]['id'] as int,
                                    name: (data[i]['name'] ?? '').toString(),
                                    // Use the actual DB column key 'imageURl' and guard nulls
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
                    // tab 2 recipes, shows generic message until user presses on recipe on homepage
                    selectedRecipeId == null
                      ? const Center(
                        child: Text(
                            'Select a recipe to view details',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        )
                      : RecipeDetailScreen(recipeId: selectedRecipeId!),

                    //tab 3 planner
                    MealPlannerScreen(),
                    //tab 4 favorites, basically same stuff as recipes
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
                              //childAspectRatio: 1.0,
                              shrinkWrap: true,
                              children: [
                                for (var i = 0; i < data.length; i++)
                                  generateCard(
                                    recipeId: data[i]['id'] as int,
                                    name: (data[i]['name'] ?? '').toString(),
                                    // Use the actual DB column key 'imageURl' and guard nulls
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
                    //tab 5 grocery list
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
                              FutureBuilder<List<Map<String, dynamic>>>(
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
                                    itemCount: data.length,
                                    itemBuilder: (context, index) {
                                      final item = data[index];
                                      return ListTile(
                                        title: Text('${item['ingredient_name']} - ${item['total_quantity']} ${item['unit']}', style: TextStyle(fontSize: 18),),
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
        // Use StatefulBuilder to update the dialog state independently
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

  final Duration duration = const Duration(milliseconds: 800);
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
      onTap: () {
        // when card is tapped, goes to recipe details screen depending on id
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipeId: widget.recipeId),
          ),
        );
      },
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: EdgeInsets.all(8.0),
            width: 250,
            height: 200,
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
                      : Image.asset(
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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