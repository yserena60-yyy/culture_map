// ignore_for_file: avoid_print, prefer_const_declarations
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final centerLat = 41.8902;
  final centerLng = 12.4922;
  
  final sparqlQuery = '''
    SELECT ?place ?placeLabel ?coords ?inception ?article WHERE {
      SERVICE wikibase:around {
        ?place wdt:P625 ?coords .
        bd:serviceParam wikibase:center "Point($centerLng $centerLat)"^^geo:wktLiteral .
        bd:serviceParam wikibase:radius "4" .
      }
      ?place wdt:P571 ?inception .
      OPTIONAL {
        ?article schema:about ?place .
        ?article schema:isPartOf <https://en.wikipedia.org/> .
      }
      SERVICE wikibase:label { bd:serviceParam wikibase:language "zh,en,fr,de". }
    }
    LIMIT 150
  ''';

  final url = Uri.parse('https://query.wikidata.org/sparql?query=${Uri.encodeComponent(sparqlQuery)}&format=json');
  try {
    final response = await http.get(url, headers: {
      'Accept': 'application/json'
    });
    print('Status code: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Response body: ${response.body}');
      return;
    }
    final data = jsonDecode(response.body);
    final bindings = data['results']['bindings'] as List;
    for (var i = 0; i < bindings.length; i++) {
      final item = bindings[i];
      final title = item['placeLabel']['value'];
      final inception = item['inception']?['value'];
      final coords = item['coords']?['value'];
      print('Item $i: title=$title, coords=$coords, inception=$inception');
    }
  } catch (e) {
    print('Error: $e');
  }
}
