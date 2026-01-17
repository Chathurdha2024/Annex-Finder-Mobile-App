class Annex {
  final String id;
  final String title;
  final String location;
  final double price;
  final int rooms; 
  final String description;
  final String contactNumber;
  final List<String> facilities;
  final String passcode;
  final DateTime datePosted;

  Annex({
    required this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.rooms, 
    required this.description,
    required this.contactNumber,
    required this.facilities,
    required this.passcode,
    required this.datePosted,
  });
}