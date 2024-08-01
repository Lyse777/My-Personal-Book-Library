import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }

  Future<void> saveSortingOrder(String sortingOrder) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sortingOrder', sortingOrder);
  }

  Future<String> getSortingOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sortingOrder') ?? 'Title';
  }

  Future<void> saveFilterCriteria(String filterCriteria) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('filterCriteria', filterCriteria);
  }

  Future<String> getFilterCriteria() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('filterCriteria') ?? 'All';
  }
}
