import 'package:firebase_database/firebase_database.dart';


class AuthService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;


  // Function to get user role
  Future<String?> getUserRole(String uid) async {
    try {
      DatabaseReference patientsRef = _database.ref('patients/$uid');
      DatabaseReference physiciansRef = _database.ref('physicians/$uid');


      // Check if user exists in patients
      DatabaseEvent patientEvent = await patientsRef.once();
      if (patientEvent.snapshot.value != null) {
        print("User found in patients!");
        return "patient";
      }


      // Check if user exists in physicians
      DatabaseEvent physicianEvent = await physiciansRef.once();
      if (physicianEvent.snapshot.value != null) {
        print("User found in physicians!");
        return "physician";
      }


      // If the user is in neither group
      print("User not found in patients or physicians!");
      return null;
    } catch (e) {
      print("Error fetching user role: $e");
      return null;
    }
  }
}



