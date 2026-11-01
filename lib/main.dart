import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/forward_calc_page.dart';
import 'pages/reverse_calc_page.dart';
import 'utils/history_manager.dart';

void main() {
  runApp(const LabCalcApp());
}

class LabCalcApp extends StatefulWidget {
  const LabCalcApp({super.key});

  @override
  State<LabCalcApp> createState() => _LabCalcAppState();
}

class _LabCalcAppState extends State<LabCalcApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  // Load saved theme from shared_preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? true;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // change theme! yayyyyyy
  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
        prefs.setBool('is_dark_mode', false);
      } else {
        _themeMode = ThemeMode.dark;
        prefs.setBool('is_dark_mode', true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // --- LIGHT THEME DEFINITION (#CBCBC0 Palette Inspired) ---
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(
          0xFFF7F7F2,
        ), // Soft sage-tinted off-white
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme.light(
          primary: Colors.blueAccent,
          surface: Color(0xFFEBEBE5), // Muted grayish-olive container tone
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF2C3E2D),
        ),
        cardColor: const Color(0xFFEBEBE5),
      ),

      // --- DARK THEME DEFINITION ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF111111),
      ),

      home: MainTabContainer(
        onToggleTheme: _toggleTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class MainTabContainer extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const MainTabContainer({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = currentThemeMode == ThemeMode.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'LabCalc Elite Suite',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? Colors.amber : Colors.blueGrey,
              ),
              onPressed: onToggleTheme,
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.blueAccent),
              onPressed: () => showHistoryBottomSheet(context),
              tooltip: 'View History',
            ),
          ],
        ),

        body: const TabBarView(
          children: [MolarMassPage(), ReactionPage(), ReverseCalcPage()],
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: const SafeArea(
            child: TabBar(
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.calculate), text: "Molar Mass"),
                Tab(icon: Icon(Icons.trending_flat), text: "Yield Matrix"),
                Tab(
                  icon: Icon(Icons.settings_backup_restore),
                  text: "Target Prep",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showHistoryBottomSheet(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F7F2),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<CalculationRecord>>(
              future: HistoryManager.loadHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final items = snapshot.data ?? [];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📜 Calculation History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        if (items.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              await HistoryManager.clearHistory();
                              setModalState(() {});
                            },
                            tooltip: 'Clear History',
                          ),
                      ],
                    ),
                    const Divider(),
                    items.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 30.0),
                            child: Center(
                              child: Text(
                                'No recent calculations saved yet.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Card(
                                  color: isDark
                                      ? const Color(0xFF111111)
                                      : const Color(0xFFEBEBE5),
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      '${item.title} • ${item.result}',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.greenAccent
                                            : Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.details,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey
                                            : Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: Text(
                                      '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black54,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
  );
}
