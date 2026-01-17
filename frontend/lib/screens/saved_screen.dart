// lib/screens/saved_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../annex_provider.dart';

class SavedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final savedList = Provider.of<AnnexProvider>(context).savedItems;

    return Scaffold(
      appBar: AppBar(title: Text("Saved Annexes")),
      body: savedList.isEmpty 
        ? Center(child: Text("No saved items yet."))
        : ListView.builder(
            itemCount: savedList.length,
            itemBuilder: (ctx, i) {
              final annex = savedList[i];
              return ListTile(
                title: Text(annex.title),
                subtitle: Text(annex.location),
                leading: Icon(Icons.favorite, color: Colors.red),
              );
            },
          ),
    );
  }
}