// ignore_for_file: library_private_types_in_public_api, annotate_overrides, overridden_fields, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/book_provider.dart';
import '../services/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  final Key? key;

  const SettingsScreen({this.key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _sortingOrder = 'TitleAsc';
  String _filterCriteria = 'All';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    String? loadedSortingOrder = await PreferencesService().getSortingOrder();
    String? loadedFilterCriteria = await PreferencesService().getFilterCriteria();

    // Validate loaded preferences
    if (['TitleAsc', 'TitleDesc', 'AuthorAsc', 'AuthorDesc', 'RatingAsc', 'RatingDesc']
        .contains(loadedSortingOrder)) {
      _sortingOrder = loadedSortingOrder;
    }

    if (['All', 'Read', 'Unread'].contains(loadedFilterCriteria)) {
      _filterCriteria = loadedFilterCriteria;
    }

    setState(() {});
    print('Loaded preferences: _sortingOrder: $_sortingOrder, _filterCriteria: $_filterCriteria');
  }

  void _savePreferences() {
    PreferencesService().saveSortingOrder(_sortingOrder);
    PreferencesService().saveFilterCriteria(_filterCriteria);
    Provider.of<BookProvider>(context, listen: false).sortBooks(_sortingOrder);
    Provider.of<BookProvider>(context, listen: false).filterBooks(_filterCriteria);
    print('Saved preferences: _sortingOrder: $_sortingOrder, _filterCriteria: $_filterCriteria');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: isDarkMode ? Colors.black : Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sorting Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                ),
                DropdownButton<String>(
                  value: _sortingOrder,
                  items: const [
                    DropdownMenuItem(value: 'TitleAsc', child: Text('Title A-Z')),
                    DropdownMenuItem(value: 'TitleDesc', child: Text('Title Z-A')),
                    DropdownMenuItem(value: 'AuthorAsc', child: Text('Author A-Z')),
                    DropdownMenuItem(value: 'AuthorDesc', child: Text('Author Z-A')),
                    DropdownMenuItem(value: 'RatingAsc', child: Text('Rating Lowest-Highest')),
                    DropdownMenuItem(value: 'RatingDesc', child: Text('Rating Highest-Lowest')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortingOrder = value!;
                    });
                    _savePreferences();
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Filter Criteria',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                ),
                DropdownButton<String>(
                  value: _filterCriteria,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Read', child: Text('Read')),
                    DropdownMenuItem(value: 'Unread', child: Text('Unread')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterCriteria = value!;
                    });
                    _savePreferences();
                  },
                ),
                const SizedBox(height: 20),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
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
