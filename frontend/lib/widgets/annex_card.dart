import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/annex_model.dart';
import '../annex_provider.dart';

class AnnexCard extends StatelessWidget {
  final Annex annex;
  final VoidCallback onTap;
  final AnnexProvider provider;

  const AnnexCard({
    required this.annex,
    required this.onTap,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = annex.images.isNotEmpty;
    final imageUrl = hasImage ? provider.getImageUrl(annex.images[0]) : null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
           
            Container(
              height: 130,
              width: 130,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        height: 130,
                        width: 130,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 130,
                          width: 130,
                          color: Color(0xFF2C2C2C),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 130,
                          width: 130,
                          color: Color(0xFF2C2C2C),
                          child: Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.blue),
                          ),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          color: Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Icons.photo, size: 40, color: Colors.blue),
                        ),
                      ),
                    ),
            ),
           
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    
                    Text(
                      annex.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                  
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.blue),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            annex.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                   
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Rs ${annex.price.toInt()}/mo",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      
                        Row(
                          children: [
                            Icon(Icons.bed, size: 14, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              "${annex.rooms} Rooms",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
           
            if (annex.images.length > 1)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "+${annex.images.length - 1}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
