class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String imagePath;
  final double rating;
  final String price;
  final String bio;
  final List<String> availableTimes;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.imagePath,
    required this.rating,
    required this.price,
    required this.bio,
    required this.availableTimes,
  });
}

// Dummy Data
final List<Doctor> dummyDoctors = [
  Doctor(
    id: '1',
    name: 'Dr. AI.L.E.E.',
    specialty: 'Pulmonologist',
    location: 'Digital Health Center',
    imagePath: 'assets/images/ai_doctor.png',
    rating: 4.9,
    price: '\$80',
    bio:
        'An advanced AI specialist in respiratory health, trained on millions of cases to provide accurate diagnosis and advice.',
    availableTimes: ['08:00 AM', '09:00 AM', '10:30 AM', '02:00 PM'],
  ),
  Doctor(
    id: '2',
    name: 'Dr. Robotnic',
    specialty: 'Thoracic Surgeon',
    location: 'Cyber Clinic, NY',
    imagePath:
        'assets/images/ai_doctor.png', // Reusing for now as requested "robotic type"
    rating: 4.8,
    price: '\$120',
    bio: 'Expert in non-invasive robotic surgery analysis and consultation.',
    availableTimes: ['11:00 AM', '01:00 PM', '03:00 PM'],
  ),
  Doctor(
    id: '3',
    name: 'Dr. Xenon',
    specialty: 'Oncologist',
    location: 'Virtual Hospital',
    imagePath: 'assets/images/ai_doctor.png',
    rating: 4.7,
    price: '\$95',
    bio: 'Specializes in cancer detection algorithms and treatment planning.',
    availableTimes: ['09:30 AM', '12:00 PM', '04:30 PM'],
  ),
];
