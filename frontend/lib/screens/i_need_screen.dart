import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../annex_provider.dart';
import '../../widgets/annex_card.dart';
import 'annex_details_screen.dart';

class INeedScreen extends StatefulWidget {
  @override
  _INeedScreenState createState() => _INeedScreenState();
}

class _INeedScreenState extends State<INeedScreen> {

  String _searchText = "";
  RangeValues _priceRange = RangeValues(0, 100000); 
  int _minRooms = 1;

  @override
  void initState() {
    super.initState();
    
    Future.microtask(() {
      Provider.of<AnnexProvider>(context, listen: false).fetchAnnexes();
    });
  }

  
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(0xFF1E1E1E),
      builder: (ctx) {
        return StatefulBuilder(
          
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Filter Results",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  Divider(color: Colors.white30),

                  
                  Text(
                    "Price Range: Rs ${_priceRange.start.round()} - Rs ${_priceRange.end.round()}",
                    style: TextStyle(color: Colors.white),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 200000, 
                    divisions: 20,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.blue.withOpacity(0.3),
                    labels: RangeLabels("${_priceRange.start.round()}",
                        "${_priceRange.end.round()}"),
                    onChanged: (values) {
                      setSheetState(() {
                        _priceRange = values;
                      });
                      setState(() {}); 
                    },
                  ),

                  SizedBox(height: 10),

                 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Min Rooms: $_minRooms",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: Colors.blue),
                            onPressed: () {
                              if (_minRooms > 1) {
                                setSheetState(() => _minRooms--);
                                setState(() {});
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline,
                                color: Colors.blue),
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
                      onPressed: () => Navigator.pop(context), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Apply Filters"),
                    ),
                  ),
                  SizedBox(height: 20), 
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

    
    final filteredItems = allItems.where((annex) {
     
      final matchText =
          annex.location.toLowerCase().contains(_searchText.toLowerCase()) ||
              annex.title.toLowerCase().contains(_searchText.toLowerCase());

      
      final matchPrice =
          annex.price >= _priceRange.start && annex.price <= _priceRange.end;

      
      final matchRooms = annex.rooms >= _minRooms;

      return matchText && matchPrice && matchRooms;
    }).toList();
    

    return Scaffold(
      appBar: AppBar(
        title: Text("Find Annex", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E1E1E),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search City or Area...",
                      hintStyle: TextStyle(color: Colors.white60),
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.blue.withOpacity(0.5)),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _searchText = val);
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _showFilterSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(Icons.tune),
                ),
              ],
            ),
          ),

          
          if (_minRooms > 1 || _priceRange.end < 100000)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text("Filters active: ",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  if (_minRooms > 1)
                    Chip(
                        label: Text("Rooms: $_minRooms+"),
                        labelStyle: TextStyle(fontSize: 10)),
                  SizedBox(width: 5),
                  Chip(
                      label: Text("Rs ${_priceRange.end.toInt()} max"),
                      labelStyle: TextStyle(fontSize: 10)),
                ],
              ),
            ),

         
          Expanded(
            child: filteredItems.isEmpty
                ? Center(child: Text("No annexes found matching filters."))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (ctx, i) {
                      final annex = filteredItems[i];
                      return AnnexCard(
                        annex: annex,
                        provider: annexData,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AnnexDetailsScreen(annex: annex)));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
