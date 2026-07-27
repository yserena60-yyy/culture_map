import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static const String _baseUrl = 'https://en.wikipedia.org/w/api.php';

  Future<List<Map<String, dynamic>>> searchLandmarks(String query) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl?action=query&format=json&generator=search&gsrnamespace=0&gsrsearch=$query&gsrlimit=10&prop=coordinates|pageimages|info&inprop=url&pithumbsize=400',
      ));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final pages = data['query']?['pages'];
      if (pages == null) return [];

      final List<Map<String, dynamic>> results = [];
      pages.forEach((key, value) {
        final coords = value['coordinates'];
        if (coords != null && coords.isNotEmpty) {
          results.add({
            'title': value['title'],
            'lat': coords[0]['lat'],
            'lng': coords[0]['lon'],
            'thumbnail': value['thumbnail']?['source'],
            'url': value['fullurl'],
            'pageid': value['pageid'],
          });
        }
      });

      return results;
    } catch (e) {
      print('Error searching landmarks: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLandmarkDetails(int pageId) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl?action=query&format=json&pageids=$pageId&prop=coordinates|extracts|pageimages&exintro=1&explaintext=1&pithumbsize=400',
      ));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final page = data['query']?['pages']?['$pageId'];
      if (page == null) return null;

      final coords = page['coordinates'];
      return {
        'title': page['title'],
        'extract': page['extract'],
        'lat': coords?[0]?['lat'],
        'lng': coords?[0]?['lon'],
        'thumbnail': page['thumbnail']?['source'],
      };
    } catch (e) {
      print('Error getting landmark details: $e');
      return null;
    }
  }
}
