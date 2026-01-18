// lib/screens/annex_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _tryDelete() async {
    final _nicController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: TextStyle(color: Colors.white),
        title: Text("Delete Ad"),
        content: TextField(
          controller: _nicController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter your NIC Number",
            hintStyle: TextStyle(color: Colors.white60),
            filled: true,
            fillColor: Color(0xFF2C2C2C),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
            ),
          ),
          keyboardType: TextInputType.text,
        ),
        actions: [
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              final success =
                  await Provider.of<AnnexProvider>(context, listen: false)
                      .deleteAnnex(
                widget.annex.id,
                _nicController.text,
              );

              Navigator.of(ctx).pop();

              if (success) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Ad Deleted!",
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Wrong NIC number!",
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnnexProvider>(context);
    final hasImages = widget.annex.images.isNotEmpty;
    final isSaved = provider.isSaved(widget.annex.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: isSaved ? Colors.red : Colors.blue,
            ),
            onPressed: () {
              provider.toggleSave(widget.annex.id, widget.annex);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isSaved ? "Removed from favorites" : "Added to favorites",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.blue),
            onPressed: _tryDelete,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            if (hasImages)
              Stack(
                children: [
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemCount: widget.annex.images.length,
                      itemBuilder: (ctx, index) {
                        final imageUrl =
                            provider.getImageUrl(widget.annex.images[index]);
                        return CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                 
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_currentImageIndex + 1}/${widget.annex.images.length}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Container(
                height: 200,
                color: Color(0xFF2C2C2C),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo, size: 50, color: Colors.blue),
                      SizedBox(height: 10),
                      Text("No images available",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs ${widget.annex.price}/mo",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.blue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Text(
                    widget.annex.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        widget.annex.location,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.bed, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        "${widget.annex.rooms} rooms",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Facilities:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    children: widget.annex.facilities
                        .map((f) => Chip(
                              label: Text(f,
                                  style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.blue.withOpacity(0.2),
                              side: BorderSide(color: Colors.blue),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Description:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    widget.annex.description,
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _phoneRevealed = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(_phoneRevealed
                          ? widget.annex.contactNumber
                          : "Tap to View Phone Number"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
