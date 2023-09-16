import 'package:shared_preferences/shared_preferences.dart';

class LinkRepository {
  Future<bool> saveLink(String link) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('link', link);
  }

  Future<String?> getLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('link');
  }
}
