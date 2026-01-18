class Annex {
  final String id;
  final String title;
  final String location;
  final double price;
  final int rooms; 
  final String description;
  final String contactNumber;
  final List<String> facilities;
  final String nicNumber;
  final DateTime datePosted;
  final List<String> images;

  Annex({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.rooms, 
    required this.description,
    required this.contactNumber,
    required this.facilities,
    required this.nicNumber,
    required this.datePosted,
    this.images = const [],
  });

 
  factory Annex.fromJson(Map<String, dynamic> json) {
    return Annex(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rooms: json['rooms'] ?? 0,
      description: json['description'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      nicNumber: json['nicNumber'] ?? '',
      datePosted: DateTime.parse(json['datePosted'] ?? DateTime.now().toIso8601String()),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'price': price,
      'rooms': rooms,
      'description': description,
      'contactNumber': contactNumber,
      'facilities': facilities,
      'nicNumber': nicNumber,
      'datePosted': datePosted.toIso8601String(),
      'images': images,
    };
  }
}