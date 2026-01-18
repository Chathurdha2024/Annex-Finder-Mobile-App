
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../annex_provider.dart';
import '../../widgets/annex_card.dart';
import 'annex_details_screen.dart';

class SavedScreen extends StatefulWidget {
  @override
  _SavedScreenState createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
   
    Future.microtask(() {
      Provider.of<AnnexProvider>(context, listen: false).initializeSavedAnnexes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnnexProvider>(context);
    final savedList = provider.savedItems;

    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Annexes", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E1E1E),
      ),
      body: savedList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    "No saved items yet.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Add favorites by clicking the heart icon",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: savedList.length,
              itemBuilder: (ctx, i) {
                final annex = savedList[i];
                return AnnexCard(
                  annex: annex,
                  provider: provider,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnnexDetailsScreen(annex: annex),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
