
class Cat {
  final String id;
  final String imageUrl;
  final String name;
  final String nameEn;
  final int index;

  Cat({required this.id,
    required this.nameEn,
    required this.index ,
    required this.imageUrl,required this.name});


  factory Cat.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Cat(
      id: documentId,
      name:json['name'] ?? '',
      nameEn:json['nameEn'] ?? '',
      index: json['num'] ??0,
      imageUrl: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': imageUrl,
      'name': name,
    };
  }
}
