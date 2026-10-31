class Place {
  final int? id;
  final String name;
  final double rating;
  final String phone;
  final String address;
  final String imagePath;

  const Place({this.id, required this.name, required this.rating,
    required this.phone, required this.address, this.imagePath = 'assets/images/1.jpg'});

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name, 'rating': rating, 'phone': phone, 'address': address, 'imagePath': imagePath,
  };

  factory Place.fromMap(Map<String, dynamic> map) => Place(
    id: map['id'] as int?,
    name: map['name'] as String,
    rating: (map['rating'] as num).toDouble(),
    phone: map['phone'] as String,
    address: map['address'] as String,
    imagePath: (map['imagePath'] as String?) ?? 'assets/images/1.jpg',
  );
}
