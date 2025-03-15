import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'scanner_page.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenChoice',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(
        toggleTheme: (bool isDarkTheme) {
          // Implement theme toggling logic here if needed
        },
        isDarkTheme: false, // Default theme is light
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkTheme;

  const HomePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkTheme,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<String> recyclingFacts = [
    "Recycling one aluminum can saves enough energy to run a TV for 3 hours.",
    "Plastic takes up to 1,000 years to decompose in landfills.",
    "Glass is 100% recyclable and can be recycled endlessly without loss in quality.",
    "Recycling a single plastic bottle can conserve enough energy to light a 60W bulb for 6 hours.",
  ];
  late ValueNotifier<String> _currentFact;
  bool _showThemePopup = false;
  bool _showSlideInMenu = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  // Variables for challenges
  int _plasticBottlesRecycled = 0;
  final int _plasticBottlesGoal = 10;
  int _aluminumCansRecycled = 0;
  final int _aluminumCansGoal = 5;
  int _glassBottlesRecycled = 0;
  final int _glassBottlesGoal = 8;
  // Confetti controller for party popper animation
  late ConfettiController _confettiController;
  // New variables for Microsoft Rewards-like challenges
  bool _isWeeklySelected = true; // Toggle between weekly and monthly
  int _totalPoints = 0; // Total points earned
  final int _dailyQuota = 100; // Daily point quota
  final int _monthlyQuota = 2000; // Monthly point quota
  // List of tasks (weekly and monthly)
  final List<Map<String, dynamic>> _weeklyTasks = [
    {"title": "Recycle 10 Plastic Bottles", "points": 50, "completed": false},
    {"title": "Recycle 5 Aluminum Cans", "points": 30, "completed": false},
    {"title": "Recycle 8 Glass Bottles", "points": 40, "completed": false},
    {"title": "Use a Reusable Bag", "points": 20, "completed": false},
    {"title": "Compost Food Waste", "points": 25, "completed": false},
  ];
  final List<Map<String, dynamic>> _monthlyTasks = [
    {"title": "Recycle 50 Plastic Bottles", "points": 200, "completed": false},
    {"title": "Recycle 30 Aluminum Cans", "points": 150, "completed": false},
    {"title": "Recycle 40 Glass Bottles", "points": 180, "completed": false},
    {"title": "Plant a Tree", "points": 100, "completed": false},
    {"title": "Reduce Energy Usage", "points": 120, "completed": false},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _currentFact = ValueNotifier<String>(
      "Recycling helps conserve natural resources.",
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      _currentFact.value =
          (recyclingFacts..shuffle()).first; // Update fact without full rebuild
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentFact.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleThemePopup() {
    setState(() {
      _showThemePopup = !_showThemePopup;
    });
    if (_showThemePopup) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeThemePopup() {
    if (_showThemePopup) {
      setState(() {
        _showThemePopup = false;
      });
      _animationController.reverse();
    }
  }

  void _toggleSlideInMenu() {
    setState(() {
      _showSlideInMenu = !_showSlideInMenu;
    });
    if (_showSlideInMenu) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeSlideInMenu() {
    if (_showSlideInMenu) {
      setState(() {
        _showSlideInMenu = false;
      });
      _animationController.reverse();
    }
  }

  // Function to complete a task and add points
  void _completeTask(int index) {
    setState(() {
      if (_isWeeklySelected) {
        if (!_weeklyTasks[index]["completed"]) {
          _weeklyTasks[index]["completed"] = true;
          _totalPoints += (_weeklyTasks[index]["points"] as int); // Cast to int
        }
      } else {
        if (!_monthlyTasks[index]["completed"]) {
          _monthlyTasks[index]["completed"] = true;
          _totalPoints +=
              (_monthlyTasks[index]["points"] as int); // Cast to int
        }
      }
      if (_totalPoints >= (_isWeeklySelected ? _dailyQuota : _monthlyQuota)) {
        _confettiController.play(); // Play confetti animation
      }
    });
  }

  // Widget to build a single task
  Widget _buildTask(Map<String, dynamic> task, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkTheme ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task["title"],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${task["points"]} points",
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.isDarkTheme ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (!task["completed"])
            ElevatedButton(
              onPressed: () => _completeTask(index),
              child: const Text("Complete"),
            ),
          if (task["completed"])
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 30,
            ),
        ],
      ),
    );
  }

  // Widget to build the overall progress bar
  Widget _buildProgressBar() {
    int quota = _isWeeklySelected ? _dailyQuota : _monthlyQuota;
    double progress = _totalPoints / quota;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDarkTheme ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _isWeeklySelected ? "Daily Progress" : "Monthly Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          // Progress Bar
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        color: progress >= 1 ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$_totalPoints/$quota points",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isDarkTheme ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget pageContent;
    if (_selectedIndex == 0) {
      pageContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Scan Your Waste",
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).iconTheme.color!,
                    width: 4.0,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 140.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScannerPage()),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity, // Take full width
              height: 100, // Fixed height for the container
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: widget.isDarkTheme
                    ? Colors.grey[800]
                    : Colors.grey[200], // Inverted color for dark mode
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: _currentFact,
                builder: (context, fact, child) {
                  return Center(
                    child: Text(
                      fact,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkTheme
                            ? Colors.white
                            : Colors.black, // Adjust text color for visibility
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      // Updated Challenges Section
      pageContent = SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Weekly and Monthly Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isWeeklySelected = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isWeeklySelected ? Colors.green : Colors.grey,
                  ),
                  child: const Text("Weekly"),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isWeeklySelected = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isWeeklySelected ? Colors.grey : Colors.green,
                  ),
                  child: const Text("Monthly"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Overall Progress Bar
            _buildProgressBar(),
            const SizedBox(height: 20),
            // Task List
            ...(_isWeeklySelected ? _weeklyTasks : _monthlyTasks)
                .asMap()
                .entries
                .map((entry) => _buildTask(entry.value, entry.key))
                .toList(),
          ],
        ),
      );
    } else {
      pageContent = const Center(
        child: Text(
          "Upcoming Content",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        _closeThemePopup();
        _closeSlideInMenu();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main Content
            Center(child: pageContent),
            // Confetti Animation
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
            // Slide-In Menu
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: 0,
              right: _showSlideInMenu
                  ? 0
                  : -MediaQuery.of(context).size.width *
                      0.6, // Slide in from the right
              child: GestureDetector(
                onTap: () {}, // Prevent taps inside the menu from closing it
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.6, // Cover slightly more than half the screen
                  height: MediaQuery.of(context).size.height,
                  color: Theme.of(context).cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _closeSlideInMenu,
                        ),
                      ),
                      // Add menu items here (empty for now)
                    ],
                  ),
                ),
              ),
            ),
            // Top-Right Menu Icon
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: _toggleSlideInMenu,
                ),
              ),
            ),
            // Top-Left Settings Icon
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RotationTransition(
                  turns: Tween(
                    begin: 0.0,
                    end: 0.25,
                  ).animate(_animationController),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _toggleThemePopup,
                  ),
                ),
              ),
            ),
            // Theme Pop-Up
            if (_showThemePopup)
              Positioned(
                top: 70,
                left: 20,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeInOut,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('☀️', style: TextStyle(fontSize: 20)),
                        Switch(
                          value: widget.isDarkTheme,
                          onChanged: widget.toggleTheme,
                          activeColor: Colors.green,
                        ),
                        const Text('🌙', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: 'Challenges',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Centers',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
