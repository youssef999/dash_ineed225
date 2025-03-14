
class Task {
  final String id;
  final String date;
  final String cat;
  final String description;
  final String end_time;
  final String maxPrice;
  final String minPrice;
  final String time;
  final String image;
  final String title;
  final String user_email;
  final String user_name;
  final String phone;
  final String isRate;
  final String status;
  final String locationLink;
  final String lat;
  final String lng;
  final String locationDes;
  final String locationName;
  final bool hasAcceptedProposal;

  Task({
    required this.id,
    required this.cat,
    required this.date,
    required this.isRate,
    required this.image,
    required this.status,
    required this.description,
    required this.lat,
    required this.lng,
    required this.end_time,
    required this.maxPrice,
    required this.minPrice,
    required this.time,
    required this.title,
    required this.user_email,
    required this.locationName,
    required this.locationDes,
    required this.locationLink,
    required this.user_name,
    required this.phone,
    required this.hasAcceptedProposal,
  });

  // Factory method to create a Task instance from a Firestore document snapshot
  factory Task.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Task(
      id: json['id'] ?? '',
      hasAcceptedProposal: json['hasAcceptedProposal'] ?? false,
      cat: json['cat'] ?? '',
      date: json['date'] ?? '',
      isRate: json['isRate'] ?? '',
      lat:json['lat']??"",
      lng:json['lng']??'',
      locationDes: json['locationDescription'] ?? '',
      locationLink: json['locationLink'] ?? '',
      locationName: json['address'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      end_time: json['end_time'] ?? '',
      maxPrice: json['maxPrice'] ?? '',
      minPrice: json['minPrice'] ?? '',
      time: json['time'] ?? '',
      title: json['title'] ?? '',
      user_email: json['user_email'] ?? '',
      user_name: json['user_name'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // Method to convert Task instance to a Map (useful for uploading data to Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'hasAcceptedProposal': hasAcceptedProposal,
      'cat': cat,
      'date': date,
      'isRate': isRate,
      'image': image,
      'description': description,
      'end_time': end_time,
      'maxPrice': maxPrice,
      'minPrice': minPrice,
      'time': time,
      'title': title,
      'user_email': user_email,
      'user_name': user_name,
      'phone': phone,
    };
  }
}
