// lib/screens/i_have_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math'; // for random passcode
import '../../annex_provider.dart';
import '../../models/annex_model.dart';

class IHaveScreen extends StatefulWidget {
  @override
  _IHaveScreenState createState() => _IHaveScreenState();
}

class _IHaveScreenState extends State<IHaveScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for Text Inputs
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController(); // <--- NEW
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Facilities Checkbox Logic
  bool _wifi = false;
  bool _parking = false;
  bool _bath = false;

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      // 1. Generate Random Passcode (4 Digits)
      final passcode = (1000 + Random().nextInt(9000)).toString();

      // 2. Create Object
      try {
        final newAnnex = Annex(
          id: Uuid().v4(),
          title: _titleController.text,
          location: _locationController.text,
          price: double.parse(_priceController.text),
          rooms: int.parse(_roomsController.text), // <--- SAVE ROOMS
          description: _descController.text,
          contactNumber: _phoneController.text,
          facilities: [
            if(_wifi) 'WiFi',
            if(_parking) 'Parking',
            if(_bath) 'Attached Bath',
          ],
          passcode: passcode,
          datePosted: DateTime.now(),
        );

        // 3. Save to Provider
        Provider.of<AnnexProvider>(context, listen: false).addAnnex(newAnnex);

        // 4. Show Passcode Alert
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Ad Posted Successfully!"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("⚠️ IMPORTANT: Save this passcode. You need it to DELETE or EDIT this ad later."),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(15),
                  color: Colors.red[50],
                  child: Text(
                    passcode, 
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.red, letterSpacing: 5)
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                _clearForm(); // Clear inputs
              }, child: Text("I Have Copied It"))
            ],
          ),
        );
      } catch (error) {
        // If user typed text into number fields somehow
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter valid numbers for Price and Rooms")));
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _locationController.clear();
    _priceController.clear();
    _roomsController.clear(); // <--- Clear rooms
    _descController.clear();
    _phoneController.clear();
    setState(() { _wifi = false; _parking = false; _bath = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post New Ad")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // TITLE
              TextFormField(
                controller: _titleController, 
                decoration: InputDecoration(
                  labelText: 'Title (e.g., Luxury Room for Rent)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title)
                ), 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              SizedBox(height: 15),

              // LOCATION
              TextFormField(
                controller: _locationController, 
                decoration: InputDecoration(
                  labelText: 'Location / City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on)
                ), 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              SizedBox(height: 15),

              // ROW: PRICE & ROOMS
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController, 
                      decoration: InputDecoration(
                        labelText: 'Rent (Rs)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money)
                      ), 
                      keyboardType: TextInputType.number, 
                      validator: (v) => v!.isEmpty ? 'Required' : null
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _roomsController, 
                      decoration: InputDecoration(
                        labelText: 'No. of Rooms',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bed)
                      ), 
                      keyboardType: TextInputType.number, 
                      validator: (v) => v!.isEmpty ? 'Required' : null
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // PHONE
              TextFormField(
                controller: _phoneController, 
                decoration: InputDecoration(
                  labelText: 'Contact Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone)
                ), 
                keyboardType: TextInputType.phone, 
                validator: (v) => v!.isEmpty ? 'Required' : null
              ),
              SizedBox(height: 15),

              // DESCRIPTION
              TextFormField(
                controller: _descController, 
                decoration: InputDecoration(
                  labelText: 'Description (Details about the place)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ), 
                maxLines: 4
              ),
              
              SizedBox(height: 20),
              Divider(),
              Text("Facilities Available:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              
              CheckboxListTile(
                title: Text("WiFi Available"), 
                secondary: Icon(Icons.wifi),
                value: _wifi, 
                onChanged: (v) => setState(() => _wifi = v!)
              ),
              CheckboxListTile(
                title: Text("Parking Space"), 
                secondary: Icon(Icons.local_parking),
                value: _parking, 
                onChanged: (v) => setState(() => _parking = v!)
              ),
              CheckboxListTile(
                title: Text("Attached Bathroom"), 
                secondary: Icon(Icons.bathtub),
                value: _bath, 
                onChanged: (v) => setState(() => _bath = v!)
              ),

              SizedBox(height: 20),
              
              // SUBMIT BUTTON
              ElevatedButton(
                onPressed: _submitData,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15), 
                  child: Text("POST ADVERTISEMENT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}