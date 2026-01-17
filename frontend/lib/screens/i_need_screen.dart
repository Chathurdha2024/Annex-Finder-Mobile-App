import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../annex_provider.dart';
import '../../models/annex_model.dart'; // Ensure this import is here
import 'annex_details_screen.dart';

class INeedScreen extends StatefulWidget {
  @override
  _INeedScreenState createState() => _INeedScreenState();
}

class _INeedScreenState extends State<INeedScreen> {
  // FILTER STATES
  String _searchText = "";
  RangeValues _priceRange = RangeValues(0, 100000); // 0 to 1 Lakh
  int _minRooms = 1;

  // Helper to show the Bottom Sheet
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder( // Needed to update state INSIDE the sheet
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filter Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Divider(),
                  
                  // 1. Price Range Slider
                  Text("Price Range: Rs ${_priceRange.start.round()} - Rs ${_priceRange.end.round()}"),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 200000, // Max limit 2 Lakhs
                    divisions: 20,
                    labels: RangeLabels(
                      "${_priceRange.start.round()}", 
                      "${_priceRange.end.round()}"
                    ),
                    onChanged: (values) {
                      setSheetState(() {
                        _priceRange = values;
                      });
                      setState(() {}); // Update main screen
                    },
                  ),

                  SizedBox(height: 10),

                  // 2. Room Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Min Rooms: $_minRooms", style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (_minRooms > 1) {
                                setSheetState(() => _minRooms--);
                                setState(() {});
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setSheetState(() => _minRooms++);
                              setState(() {});
                            },
                          ),
                        ],
                      )
                    ],
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context), // Close sheet
                      child: Text("Apply Filters"),
                    ),
                  ),
                  SizedBox(height: 20), // Bottom padding
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final annexData = Provider.of<AnnexProvider>(context);
    final allItems = annexData.items;

    // --- FILTER LOGIC STARTS HERE ---
    final filteredItems = allItems.where((annex) {
      // 1. Check Text (Location OR Title)
      final matchText = 
          annex.location.toLowerCase().contains(_searchText.toLowerCase()) || 
          annex.title.toLowerCase().contains(_searchText.toLowerCase());
      
      // 2. Check Price
      final matchPrice = 
          annex.price >= _priceRange.start && 
          annex.price <= _priceRange.end;

      // 3. Check Rooms
      final matchRooms = annex.rooms >= _minRooms;

      return matchText && matchPrice && matchRooms;
    }).toList();
    // --- FILTER LOGIC ENDS HERE ---

    return Scaffold(
      appBar: AppBar(title: Text("I Need (Find Annex)")),
      body: Column(
        children: [
          // SEARCH BAR & FILTER BUTTON
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search City or Area...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchText = val;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                // Filter Icon Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50], 
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue)
                  ),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: Colors.blue),
                    onPressed: _showFilterSheet,
                  ),
                )
              ],
            ),
          ),
          
          // ACTIVE FILTERS CHIPS (Visual Feedback)
          if (_minRooms > 1 || _priceRange.end < 100000)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text("Filters active: ", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  if(_minRooms > 1) Chip(label: Text("Rooms: $_minRooms+"), labelStyle: TextStyle(fontSize: 10)),
                  SizedBox(width: 5),
                  Chip(label: Text("Rs ${_priceRange.end.toInt()} max"), labelStyle: TextStyle(fontSize: 10)),
                ],
              ),
            ),

          // LIST VIEW
          Expanded(
            child: filteredItems.isEmpty 
            ? Center(child: Text("No annexes found matching filters."))
            : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (ctx, i) {
                final annex = filteredItems[i];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: InkWell( // Makes card clickable
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AnnexDetailsScreen(annex: annex)
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          // Thumbnail
                          Container(
                            width: 80, height: 80, 
                            color: Colors.grey[300],
                            child: Icon(Icons.home, size: 40, color: Colors.grey),
                          ),
                          SizedBox(width: 10),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(annex.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(annex.location, style: TextStyle(color: Colors.grey[600])),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.bed, size: 16, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text("${annex.rooms} Beds"),
                                    SizedBox(width: 15),
                                    Text("Rs ${annex.price.toInt()}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}