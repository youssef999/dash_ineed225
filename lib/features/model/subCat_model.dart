class SubCat {
  final String id;
  final String cat;
  final String image;
  final String name;
  final String nameEn;
  final int index;


  SubCat({required this.id, required this.index,required this.image,
    required this.nameEn,
    required this.cat,required this.name});


  factory SubCat.fromFirestore(Map<String, dynamic> json, String documentId) {
    return SubCat(
      id: documentId,
      name:json['name'] ?? '',
      nameEn: json['nameEn']??'',
      image: json['image'] ?? '',
      index: json['index']??1,
      cat: json['cat'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cat': cat,
      'name': name,
      'image':image
    };
  }
}
