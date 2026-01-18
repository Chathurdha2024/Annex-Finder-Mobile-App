import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../annex_provider.dart';
import '../../models/annex_model.dart';

class IHaveScreen extends StatefulWidget {
  @override
  _IHaveScreenState createState() => _IHaveScreenState();
}

class _IHaveScreenState extends State<IHaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nicController = TextEditingController();

  
  List<XFile> _selectedImages = [];

 
  bool _wifi = false;
  bool _parking = false;
  bool _bath = false;
  bool _isLoading = false;

 
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking images: $e")),
      );
    }
  }

  
  Future<void> _takPhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error taking photo: $e")),
      );
    }
  }

 
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

 
  Widget _buildImagePreview(XFile imageFile) {
    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            );
          } else {
            return Container(
              width: 100,
              height: 100,
              color: Color(0xFF2C2C2C),
              child: Icon(Icons.error, color: Colors.blue),
            );
          }
        } else {
          return Container(
            width: 100,
            height: 100,
            color: Color(0xFF2C2C2C),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
       
        final newAnnex = Annex(
          id: Uuid().v4(),
          title: _titleController.text,
          location: _locationController.text,
          price: double.parse(_priceController.text),
          rooms: int.parse(_roomsController.text),
          description: _descController.text,
          contactNumber: _phoneController.text,
          facilities: [
            if (_wifi) 'WiFi',
            if (_parking) 'Parking',
            if (_bath) 'Attached Bath',
          ],
          nicNumber: _nicController.text,
          datePosted: DateTime.now(),
          images: [],
        );

       
        dynamic result;
        if (_selectedImages.isNotEmpty) {
          result = await Provider.of<AnnexProvider>(context, listen: false)
              .addAnnexWithImages(newAnnex, _selectedImages);
        } else {
          result = await Provider.of<AnnexProvider>(context, listen: false)
              .addAnnex(newAnnex);
        }

        if (result != null) {
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Color(0xFF1E1E1E),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
              contentTextStyle: TextStyle(color: Colors.white),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue),
                  SizedBox(width: 15),
                  Text("Success!"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚠️ IMPORTANT: Save your NIC number. You need it to DELETE or EDIT this ad later.",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      _nicController.text,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  if (_selectedImages.isNotEmpty)
                    Text(
                      "✅ ${_selectedImages.length} image(s) uploaded successfully!",
                      style: TextStyle(color: Colors.blue),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); 
                    _clearForm();
                  
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text("I Have Noted It",
                      style: TextStyle(color: Colors.blue)),
                )
              ],
            ),
          );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to post ad. Please try again."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (error) {
        print(" Detailed error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $error"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 7),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _locationController.clear();
    _priceController.clear();
    _roomsController.clear();
    _descController.clear();
    _phoneController.clear();
    _nicController.clear();
    setState(() {
      _wifi = false;
      _parking = false;
      _bath = false;
      _selectedImages = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post New Ad", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E1E1E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // TITLE
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title (e.g., Luxury Room for Rent)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.title, color: Colors.blue),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15),

              // LOCATION
              TextFormField(
                controller: _locationController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Location / City',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15),

              // ROW: PRICE & ROOMS
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Rent (Rs)',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        prefixIcon:
                            Icon(Icons.attach_money, color: Colors.blue),
                        filled: true,
                        fillColor: Color(0xFF2C2C2C),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _roomsController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'No. of Rooms',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        prefixIcon: Icon(Icons.bed, color: Colors.blue),
                        filled: true,
                        fillColor: Color(0xFF2C2C2C),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contact Phone Number',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.phone, color: Colors.blue),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15),

              
              TextFormField(
                controller: _nicController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'National ID Card (NIC) Number',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  prefixIcon: Icon(Icons.badge, color: Colors.blue),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                keyboardType: TextInputType.text,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 15),

              
              TextFormField(
                controller: _descController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Description (Details about the place)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                maxLines: 4,
              ),

              SizedBox(height: 20),
              Divider(color: Colors.white30),

              
              Text(
                "Add Images (Max 10)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _pickImages,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 2),
                      padding: EdgeInsets.all(24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, color: Colors.blue, size: 32),
                        SizedBox(height: 8),
                        Text(
                          "Add Photo",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _takPhoto,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 2),
                      padding: EdgeInsets.all(24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, color: Colors.blue, size: 32),
                        SizedBox(height: 8),
                        Text(
                          "Take Photo",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              
              if (_selectedImages.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF2C2C2C),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected Images (${_selectedImages.length}/10)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (ctx, index) => Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildImagePreview(
                                      _selectedImages[index]),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.blue,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 20),
              Divider(color: Colors.white30),

              Text(
                "Facilities Available:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),

              CheckboxListTile(
                title: Text("WiFi Available",
                    style: TextStyle(color: Colors.white)),
                secondary: Icon(Icons.wifi, color: Colors.blue),
                value: _wifi,
                onChanged: (v) => setState(() => _wifi = v!),
                checkColor: Colors.white,
                activeColor: Colors.blue,
              ),
              CheckboxListTile(
                title: Text("Parking Space",
                    style: TextStyle(color: Colors.white)),
                secondary: Icon(Icons.local_parking, color: Colors.blue),
                value: _parking,
                onChanged: (v) => setState(() => _parking = v!),
                checkColor: Colors.white,
                activeColor: Colors.blue,
              ),
              CheckboxListTile(
                title: Text("Attached Bathroom",
                    style: TextStyle(color: Colors.white)),
                secondary: Icon(Icons.bathtub, color: Colors.blue),
                value: _bath,
                onChanged: (v) => setState(() => _bath = v!),
                checkColor: Colors.white,
                activeColor: Colors.blue,
              ),

              SizedBox(height: 20),

             
              ElevatedButton(
                onPressed: _isLoading ? null : _submitData,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          "POST ADVERTISEMENT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
