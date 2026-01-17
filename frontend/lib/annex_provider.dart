// lib/annex_provider.dart

import 'package:flutter/foundation.dart';
import 'models/annex_model.dart';
import 'package:uuid/uuid.dart';

class AnnexProvider with ChangeNotifier {
  // 1. The List of all Annexes (Mock Data for now)
final List<Annex> _items = [
    Annex(
      id: '1',
      title: 'Luxury Studio',
      location: 'Colombo 03',
      price: 45000,
      rooms: 1, // <--- Added this
      description: 'Beautiful annex near the beach.',
      contactNumber: '0771234567',
      facilities: ['WiFi', 'AC', 'Attached Bath'],
      passcode: '1234', 
      datePosted: DateTime.now(),
    ),
    // Add a second one so you can test filtering
    Annex(
      id: '2',
      title: 'Family House',
      location: 'Kandy',
      price: 25000,
      rooms: 2, // <--- Added this
      description: 'Quiet place.',
      contactNumber: '0777777777',
      facilities: ['Parking', 'Kitchen'],
      passcode: '1234', 
      datePosted: DateTime.now(),
    ),
  ];

  // 2. Saved/Bookmarked IDs
  final Set<String> _savedIds = {};

  // Getters
  List<Annex> get items => [..._items];
  List<Annex> get savedItems => _items.where((x) => _savedIds.contains(x.id)).toList();

  // ACTIONS

  // Add new Ad
  void addAnnex(Annex annex) {
    _items.add(annex);
    notifyListeners(); // Tells UI to update
  }

  // Delete Ad (Only if passcode matches)
  bool deleteAnnex(String id, String inputPasscode) {
    final index = _items.indexWhere((annex) => annex.id == id);
    if (index >= 0 && _items[index].passcode == inputPasscode) {
      _items.removeAt(index);
      notifyListeners();
      return true; // Success
    }
    return false; // Wrong code
  }

  // Toggle Save/Bookmark
  void toggleSave(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();
  }

  bool isSaved(String id) {
    return _savedIds.contains(id);
  }
}