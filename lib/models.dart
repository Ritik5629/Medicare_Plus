class UserProfile {
  final String name;
  final int age;
  final String gender;
  final String medicalHistory;
  final List<String> allergies;
  final String? profilePictureUrl;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.medicalHistory,
    required this.allergies,
    this.profilePictureUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      medicalHistory: map['medicalHistory'] ?? '',
      allergies: List<String>.from(map['allergies'] ?? []),
      profilePictureUrl: map['profilePictureUrl'],
    );
  }
}

class MedicineReminder {
  final String id;
  final String name;
  final String dosage;
  final List<String> times; // morning, afternoon, night
  final DateTime startDate;
  final DateTime? endDate;

  MedicineReminder({
    required this.id,
    required this.name,
    required this.dosage,
    required this.times,
    required this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'times': times,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory MedicineReminder.fromMap(Map<String, dynamic> map) {
    return MedicineReminder(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      times: List<String>.from(map['times'] ?? []),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
    );
  }
}

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String location;
  final String notes;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.location,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'specialty': specialty,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      doctorName: map['doctorName'] ?? '',
      specialty: map['specialty'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      location: map['location'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}

class MedicalReport {
  final String id;
  final String name;
  final String fileUrl;
  final DateTime uploadDate;
  final String type;

  MedicalReport({
    required this.id,
    required this.name,
    required this.fileUrl,
    required this.uploadDate,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'fileUrl': fileUrl,
      'uploadDate': uploadDate.toIso8601String(),
      'type': type,
    };
  }

  factory MedicalReport.fromMap(Map<String, dynamic> map) {
    return MedicalReport(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadDate: DateTime.parse(map['uploadDate']),
      type: map['type'] ?? '',
    );
  }
}
