
class Proposal {
  final String id;
  final String date;
  final String cat;
  final String email;
  final String name;
  final String description;
  final String details;
  final String phone;
   final String endDate;
  final String task_id;
  final String price;
  final String status;
  final String date2;
  final bool offer;

  final String lat;
  final String lng;
  final String locationName;
  final String locationDes;
  final String dateEndTask;

  final String image2;
  final String time;
  final String workerEmail;
  final String image;
  final bool isRate;
  final String title;
  final String user_phone;
  final String user_name;
  final String user_email;
  final String title2;

  Proposal(
      {required this.id,
        this.workerEmail='',
      required this.cat,
        this.date2='',
        this.locationDes='',
        this.locationName='',
        this.endDate='',
        this.offer=false,
        this.lat='',
        this.dateEndTask='',
        this.name='',
        this.lng='',
        this.title2='',
      required this.details,
        this.isRate=false,
      required this.task_id,
      required this.user_name,
      required this.email,
      required this.user_phone,
      required this.phone,
      required this.status,
      required this.date,
      required this.image,
      required this.description,
      required this.price,
      required this.time,
      required this.image2,
      required this.title,
      required this.user_email});

  // Factory method to create an Ad instance from a Firestore document snapshot
  factory Proposal.fromFirestore(Map<String, dynamic> json, String documentId) {
    return Proposal(
      id: json['id'] ?? '',
      workerEmail: json['worker_email']??'x',
      dateEndTask:json['dateEndTask']??'rrr',

      lat: json['Lat']??'',
      lng: json['Lng']??'',
      endDate: json['endDate']??"",
      offer:json['offer']??false,
      name: json['name']??"",
      locationName: json['locationName']??'',
      locationDes: json['locationDes']??'',

      title2: json['title']??'x',
      task_id: json['task_id'] ?? '',
      date2: json['date']??'',
      isRate: json['isRate'] ?? false,
      cat: json['cat'] ?? '',
      user_phone: json['user_phone'] ?? '',
      user_name: json['user_name'] ?? '',
      details: json['details'] ?? '',
      date: json['task_date'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['task_image'] ?? '',
      image2: json['image'] ?? '',
      status: json['status'] ?? '',
      description: json['task_description'] ?? '',
      price: json['price'] ?? '',
      time: json['task_time'] ?? '',
      title: json['task_title'] ?? '',
      user_email: json['user_email'] ?? '',
      // Default to empty string if no image
    );
  }
  // Method to convert Ad instance to a Map (useful for uploading data to Firestore)
}
