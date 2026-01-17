// lib/screens/annex_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/annex_model.dart';
import '../../annex_provider.dart';

class AnnexDetailsScreen extends StatefulWidget {
  final Annex annex;
  AnnexDetailsScreen({required this.annex});

  @override
  _AnnexDetailsScreenState createState() => _AnnexDetailsScreenState();
}

class _AnnexDetailsScreenState extends State<AnnexDetailsScreen> {
  bool _phoneRevealed = false;

  void _tryDelete() {
    final _passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Owner Delete"),
        content: TextField(
          controller: _passController,
          decoration: InputDecoration(hintText: "Enter 4-digit Passcode"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              bool success = Provider.of<AnnexProvider>(context, listen: false)
                  .deleteAnnex(widget.annex.id, _passController.text);
              
              Navigator.of(ctx).pop(); // Close dialog
              if (success) {
                 Navigator.of(context).pop(); // Go back to list
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ad Deleted!")));
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Wrong Passcode!"), backgroundColor: Colors.red));
              }
            },
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        actions: [
          IconButton(icon: Icon(Icons.delete), onPressed: _tryDelete)
        ],
      ),
      body: Column(
        children: [
          Container(height: 200, color: Colors.grey[300], child: Center(child: Icon(Icons.photo, size: 50))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rs ${widget.annex.price}/mo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                    IconButton(icon: Icon(Icons.share), onPressed: (){}),
                  ],
                ),
                Text(widget.annex.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(widget.annex.location, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 20),
                Text("Facilities:", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(spacing: 10, children: widget.annex.facilities.map((f) => Chip(label: Text(f))).toList()),
                SizedBox(height: 20),
                Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.annex.description),
                SizedBox(height: 30),
                
                // Reveal Phone Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _phoneRevealed = true),
                    child: Text(_phoneRevealed ? widget.annex.contactNumber : "Tap to View Phone Number"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _phoneRevealed ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}