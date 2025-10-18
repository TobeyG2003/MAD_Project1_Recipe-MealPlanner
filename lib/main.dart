import 'package:flutter/material.dart';

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

      @override
      void initState() {
        super.initState();
        _tabController = TabController(length: 5, vsync: this);
        _tabController.animation!.addListener(() {
        setState(() {
          
        });
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
                      image: AssetImage('tiledbackground.jpg'),
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
                    //tab 1
                    Center(child: Text('Home Content')),
                    //tab 2
                    Center(child: Text('Settings Content')),
                    //tab 3
                    Center(child: Text('Profile Content')),
                    //tab 4
                    Center(child: Text('Notifications Content')),
                    //tab 5
                    Center(child: Text('Info Content')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}