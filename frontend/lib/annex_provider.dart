import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'models/annex_model.dart';

class AnnexProvider with ChangeNotifier {
  
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/annexes';
    } else {
      return 'http://10.0.2.2:3000/api/annexes';
    }
  }

  static String get _baseUrlHost {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  
  final List<Annex> _items = [];
  final List<Annex> _savedAnnexes = [];
  
  List<Annex> get items => [..._items];
  List<Annex> get savedItems => [..._savedAnnexes];

  Future<void> initializeSavedAnnexes() async {
    await _loadSavedAnnexesFromJson();
  }

  
  Future<void> fetchAnnexes() async {
    try {
      debugPrint(" Fetching annexes from $_baseUrl");
      final response = await http.get(Uri.parse(_baseUrl));

      debugPrint(" Fetch response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        debugPrint(" Got ${data.length} annexes from backend");

        _items.clear();
        _items.addAll(
          data.map((e) => Annex.fromJson(e as Map<String, dynamic>)).toList(),
        );
        debugPrint(" Items in provider now: ${_items.length}");

        notifyListeners();

        debugPrint(" Listeners notified");
      } else {
        debugPrint(" Fetch failed with status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint(" Fetch error: $e");
    }
  }

 
  Future<Annex?> addAnnex(Annex annex) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": annex.title,
          "location": annex.location,
          "price": annex.price,
          "rooms": annex.rooms,
          "description": annex.description,
          "contactNumber": annex.contactNumber,
          "facilities": annex.facilities,
          "nicNumber": annex.nicNumber,
        }),
      );

      debugPrint(" Response status (no images): ${response.statusCode}");

      if (response.statusCode == 201) {
        debugPrint(" Annex created without images");
        await fetchAnnexes(); 
        return annex;
      } else {
        debugPrint(" Error creating annex: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Add annex error: $e");
      return null;
    }
  }

 
  Future<Annex?> addAnnexWithImages(Annex annex, List<XFile> imageFiles) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      
      request.fields['title'] = annex.title;
      request.fields['location'] = annex.location;
      request.fields['price'] = annex.price.toString();
      request.fields['rooms'] = annex.rooms.toString();
      request.fields['description'] = annex.description;
      request.fields['contactNumber'] = annex.contactNumber;
      request.fields['facilities'] = jsonEncode(annex.facilities);
      request.fields['nicNumber'] = annex.nicNumber;

      
      for (var imageFile in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromBytes(
            'images',
            await imageFile.readAsBytes(),
            filename: imageFile.name,
          ),
        );
      }

      debugPrint(" Uploading to: $_baseUrl");
      debugPrint(" Form fields: ${request.fields}");
      debugPrint(" Images count: ${request.files.length}");

      final response = await request.send();

      debugPrint(" Response status: ${response.statusCode}");

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        debugPrint(" Response body: $responseBody");
        final data = jsonDecode(responseBody);
        await fetchAnnexes();
        return Annex.fromJson(data);
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint(" Error response status: ${response.statusCode}");
        debugPrint(" Error response body: $responseBody");
        debugPrint(" Error response headers: ${response.headers}");
        throw Exception(
            "Backend error: ${response.statusCode} - $responseBody");
      }
    } catch (e) {
      debugPrint(" Add annex with images error: $e");
      return null;
    }
  }

  Future<Annex?> uploadImagesToAnnex(
      String annexId, List<XFile> imageFiles) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));

      request.fields['id'] = annexId;

      for (var imageFile in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromBytes(
            'images',
            await imageFile.readAsBytes(),
            filename: imageFile.name,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        await fetchAnnexes();
        return Annex.fromJson(data);
      } else {
        debugPrint("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Upload images error: $e");
      return null;
    }
  }

 
  Future<bool> deleteAnnex(String id, String nicNumber) async {
    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id": id, "nicNumber": nicNumber}),
    );

    if (response.statusCode == 200) {
      await fetchAnnexes();
      return true;
    }
    return false;
  }

  Future<void> toggleSave(String id, Annex annex) async {
    final index = _savedAnnexes.indexWhere((a) => a.id == id);
    
    if (index != -1) {
      
      _savedAnnexes.removeAt(index);
    } else {
      
      _savedAnnexes.add(annex);
    }
    
    
    await _saveSavedAnnexesToJson();
    notifyListeners();
  }

  bool isSaved(String id) => _savedAnnexes.any((a) => a.id == id);

 
 
  Future<File> _getSavedAnnexesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/saved_annexes.json');
  }

  
  Future<void> _saveSavedAnnexesToJson() async {
    try {
      final file = await _getSavedAnnexesFile();
      
     
      final jsonData = _savedAnnexes.map((annex) => annex.toJson()).toList();
      
     
      await file.writeAsString(jsonEncode(jsonData), flush: true);
      
      debugPrint(" Saved ${_savedAnnexes.length} annexes to JSON file");
      debugPrint("File path: ${file.path}");
    } catch (e) {
      debugPrint(" Error saving to JSON: $e");
    }
  }

  
  Future<void> _loadSavedAnnexesFromJson() async {
    try {
      final file = await _getSavedAnnexesFile();
      
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString) as List<dynamic>;
        
        _savedAnnexes.clear();
        _savedAnnexes.addAll(
          jsonData.map((e) => Annex.fromJson(e as Map<String, dynamic>)).toList(),
        );
        
        debugPrint(" Loaded ${_savedAnnexes.length} annexes from JSON file");
        notifyListeners();
      } else {
        debugPrint("ℹ No saved annexes file found");
      }
    } catch (e) {
      debugPrint(" Error loading from JSON: $e");
    }
  }

  
  String getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '$_baseUrlHost$imagePath';
  }
}
