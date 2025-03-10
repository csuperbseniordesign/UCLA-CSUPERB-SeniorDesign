// import 'package:flutter/material.dart';
// import 'package:telematics_sdk_example/screens/physicianUI/patient_display_screen.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:telematics_sdk_example/screens/physicianUI/physician_settings_screen.dart';
// import 'package:telematics_sdk_example/screens/physicianUI/physician_tutorial_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import "dart:collection";
// const _sizedBoxSpace = SizedBox(height: 24);

// class PhysicianHomeScreen extends StatefulWidget {
//   PhysicianHomeScreen({Key? key}) : super(key: key);

//   @override
//   _PhysicianHomeScreenState createState() => _PhysicianHomeScreenState();
// }

// class _PhysicianHomeScreenState extends State<PhysicianHomeScreen> {
//   String docName = "";
//   User? currentUser = FirebaseAuth.instance.currentUser;
//   Map<String, String> patientList = {};
//   List<String> summaryScores = [];

//   @override
//   void initState() {
//     // super.initState();
//     loadPatients();
//     super.initState();
//     // _listItems();
//   }

//   Future<Map<String, String>> getPatients() async {
//     List<String> emails = [];
//     List<String> accessTokens = [];
//     Map<String, String> patientList = <String, String>{};

//     DatabaseReference ref = FirebaseDatabase.instance.ref('patients');
//     User? currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser != null) {
//       String uid = currentUser.uid;
//       try {
//         DatabaseEvent event = await ref.once();
//         Map<dynamic, dynamic> patients =
//             event.snapshot.value as Map<dynamic, dynamic>;

//         patients.forEach((key, value) async {
//           String patientAT = '${value['accessToken']}';
//           String patientEmail = '${value['email']}';

//           if ('${value['physicianID']}' == uid) {
//             accessTokens.add(patientAT);
//             emails.add(patientEmail);
//           }
//         });

//         patientList = Map.fromIterables(emails, accessTokens);
//       SplayTreeMap<String, String> sortedList =
//       SplayTreeMap<String,String>.from(patientList);
//       patientList = sortedList;

//       } catch (e) {
//         print(e.toString());
//         // Handle errors or return an empty list
//       }
//     }
//     setState(() {});
//     return patientList;
//   }

//   Future<String> fetchSummarySafetyScore(
//       String startDate, String endDate, String authToken) async {
//     var client = http.Client();
//     String statistics = '';
//     try {
//       var url =
//           Uri.parse('https://api.telematicssdk.com/indicators/v2/Scores/safety')
//               .replace(queryParameters: {
//         'StartDate': startDate,
//         'EndDate': endDate,
//       });

//       final response = await client.get(
//         url,
//         headers: {
//           'accept': 'application/json',
//           'authorization': 'Bearer $authToken',
//         },
//       );
//       if (response.statusCode == 200) {
//         Map<String, dynamic> data = jsonDecode(response.body);
//         if (data["Result"] != null) {
//           statistics = data["Result"]["SafetyScore"].toString();
//         } else {
//           statistics = "0";
//         }
//       } else {
//         print(
//             'Failed to fetch daily statistics, status code: ${response.statusCode}, response: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching daily statistics: $e');
//     } finally {
//       client.close();
//     }
//     setState(() {});
//     return statistics;
//   }

//   String patients = "";
//   String summaryScore = "";
//   List<ListTile> patientsAndScores = [];

//   void loadPatients() async {
//   ListTile tile;
//   try {
//     var items = await getPatients();
//     patientList = items;
//     List<ListTile> tempPatientsAndScores = [];

//     if (items.isNotEmpty) {
//       List<String> keys = items.keys.toList();
//       for (var i = 0; i < keys.length; i++) {
//         String key = keys[i];
//         String value = items[key]!;
//         summaryScore =
//             await fetchSummarySafetyScore("2024-01-01", "2024-10-10", value);

//         if (summaryScore.isNotEmpty) {
//           summaryScores.add(summaryScore);
//           double s = double.parse(summaryScore);
//           if (s >= 80 && s < 101) {
//             tile = new ListTile(
//                 tileColor: Color.fromARGB(255, 68, 125, 171),
//                 title: Text(key),
//                 subtitle: Text("Summary Score: " + summaryScore),
//                 onTap: () {
//                   Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => PatientDisplayScreen(key, value)));
//                 },
//                 shape: Border(
//                   bottom: BorderSide(color: Colors.black),
//                 ));
//           } else if (s >= 60 && s < 80) {
//             tile = new ListTile(
//                 tileColor: Color.fromARGB(255, 106, 121, 134),
//                 title: Text(key),
//                 subtitle: Text("Summary Score: " + summaryScore),
//                 shape: Border(
//                   bottom: BorderSide(color: Colors.black),
//                 ));
//           } else if (s == 0) {
//             tile = new ListTile(
//                 tileColor: Color.fromARGB(255, 189, 189, 198),
//                 title: Text(key),
//                 subtitle: Text("Summary Score: -"),
//                 shape: Border(
//                   bottom: BorderSide(color: Colors.black),
//                 ));
//           } else {
//             tile = new ListTile(
//                 tileColor: Color.fromARGB(255, 249, 0, 0),
//                 title: Text(key),
//                 subtitle: Text("Summary Score: " + summaryScore),
//                 shape: Border(bottom: BorderSide(color: Colors.black)));
//           }
//           tempPatientsAndScores.add(tile);
//         }
//       }

//       setState(() {
//         patientsAndScores = tempPatientsAndScores;
//       });
//     }
//   } catch (e) {
//     print("Error loading patients: $e");
//   }
// }
//   // void loadPatients() async {
//   //   ListTile tile;
//   //   try {
//   //     var items = await getPatients();
//   //     patientList = items;
//   //     if (items.isNotEmpty) {
//   //       patientList.forEach((key, value) async {
//   //         summaryScore =
//   //             await fetchSummarySafetyScore("2024-01-01", "2024-10-10", value);
//   //         if (summaryScore.isNotEmpty) {
//   //           summaryScores.add(summaryScore);
//   //           double s = double.parse(summaryScore);
//   //           if (s >= 80 && s < 101) {
//   //             tile = new ListTile(
//   //                 tileColor: Color.fromARGB(255, 68, 125, 171),
//   //                 title: Text(key),
//   //                 subtitle: Text("Summary Score: " + summaryScore),
//   //                 onTap: () {
//   //                   Navigator.of(context).push(MaterialPageRoute(
//   //                       builder: (context) =>
//   //                           PatientDisplayScreen(key, value)));
//   //                 },
//   //                 shape: Border(
//   //                   bottom: BorderSide(color: Colors.black),
//   //                 ));
//   //             patientsAndScores.add(tile);
//   //           } else if (s >= 60 && s < 80) {
//   //             tile = new ListTile(
//   //                 tileColor: Color.fromARGB(255, 106, 121, 134),
//   //                 title: Text(key),
//   //                 subtitle: Text("Summary Score: " + summaryScore),
//   //                 shape: Border(
//   //                   bottom: BorderSide(color: Colors.black),
//   //                 ));
//   //             patientsAndScores.add(tile);
//   //           } else if (s == 0) {
//   //             tile = new ListTile(
//   //                 tileColor: Color.fromARGB(255, 189, 189, 198),
//   //                 title: Text(key),
//   //                 subtitle: Text("Summary Score: -"),
//   //                 shape: Border(
//   //                   bottom: BorderSide(color: Colors.black),
//   //                 ));
//   //             patientsAndScores.add(tile);
//   //           } else {
//   //             ListTile tile = new ListTile(
//   //                 tileColor: Color.fromARGB(255, 249, 0, 0),
//   //                 title: Text(key),
//   //                 subtitle: Text("Summary Score: " + summaryScore),
//   //                 shape: Border(bottom: BorderSide(color: Colors.black)));
//   //             patientsAndScores.add(tile);
//   //           }
//   //         }
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print("Error loading patients: $e");
//   //   }
//   //   // if(patientsAndScores.isNotEmpty){
//   //   //   patientsAndScores.sort((a, b) => a.title?.compareTo(b.title?));
//   //   // }
//   //   // patientsAndScores.sort((a, b) => a.title?.toString.compareTo(b.title?.toString));
//   //   setState(() {});
//   // }

//   int _selectedIndex = 0;
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       if (index == 1) {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => SettingsScreen()));
//       }
//     });
//   }

//   Widget _bottomNav() {
//     return BottomNavigationBar(
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.settings),
//           label: 'Settings',
//         ),
//       ],
//       currentIndex: _selectedIndex,
//       selectedItemColor: Color.fromARGB(255, 103, 139, 183),
//       onTap: _onItemTapped,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView(
//         shrinkWrap: false,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         children: [
//           Row(
//             children: [
//               Padding(padding: EdgeInsets.only(top: 200, right: 150)),
//               Text('Home', style: TextStyle(color: Colors.black, fontSize: 20)),
//               Padding(padding: EdgeInsets.only(right: 100)),
//               IconButton(
//                 icon: Icon(
//                   Icons.info_outline,
//                   size: 25,
//                   color: Colors.black,
//                 ),
//                 onPressed: () {
//                   showDialog(
//                       context: context, builder: (context) => Tutorial());
//                 },
//               ),
//             ],
//           ),
//           // Column(children: _listItems()),
//           Column(children: patientsAndScores),
//           _sizedBoxSpace,
//           _sizedBoxSpace,
//         ],
//       ),
//       bottomNavigationBar: _bottomNav(),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:telematics_sdk_example/screens/physicianUI/patient_display_screen.dart';
import 'package:telematics_sdk_example/screens/physicianUI/physician_tutorial_screen.dart';

class PhysicianHomeScreen extends StatefulWidget {
  const PhysicianHomeScreen({super.key});

  @override
  _PhysicianHomeScreenState createState() => _PhysicianHomeScreenState();
}

class _PhysicianHomeScreenState extends State<PhysicianHomeScreen> {
  List<Map<dynamic, dynamic>> _patientsList = [];
  List<String> _summaryScores = [];
  List<Map<dynamic, dynamic>> _filteredPatientsList = [];
  TextEditingController _filterController = TextEditingController();
  String uid = "";
  // Map<String, String> listSortedByScore = Map();
  List<String> _sortedPatients = [];
  List<String> _sortedScores = [];
  Map<String, String> _sortedMap = Map();
  TextEditingController _filterSortedController = TextEditingController();

  // Initial value (email by default)
  String dropdownvalue = 'Sort by email';
  // List of items in filter menu
  var items = [
    'Sort by email',
    'Sort by low safety score',
  ];

  @override
  void initState() {
    getUID();
    super.initState();
    _fetchPatients();
    _filterController.addListener(_filterPatientsList);
    _filterSortedController.addListener(_filterSortedPatientsList);
  }

  void getUID() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        uid = currentUser.uid;
      });
    }
  }

  Future<void> _deletePatient(String patientId, String accessToken) async {
  DatabaseReference patientRef = FirebaseDatabase.instance.ref('patients/$patientId');
  DatabaseReference userTokenRef = FirebaseDatabase.instance.ref('userTokens/$accessToken');

  try {
    await patientRef.remove(); // Delete patient
    await userTokenRef.remove(); // Delete corresponding token

    print("Patient and token deleted successfully.");
  } catch (error) {
    print("Error deleting patient: $error");
  }
}


  Future<void> _fetchPatients() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('patients');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      List<Map<dynamic, dynamic>> patients = [];
      List<String> scores = [];
      event.snapshot.children.forEach((DataSnapshot snapshot) async {
        var patient = Map<dynamic, dynamic>.from(snapshot.value as Map);
        patient['key'] = snapshot.key;
        if ('${patient['physicianID']}' == uid) {
          patients.add(patient);
        }
      });
      patients.sort((a, b) {
        String emailA = a['email']?.toLowerCase() ?? '';
        String emailB = b['email']?.toLowerCase() ?? '';
        return emailA.compareTo(emailB);
      });

       // Print patient list in console
    print("Fetched Patients:");
    for (var patient in patients) {
      print("Email: ${patient['email']}, ID: ${patient['key']}");
      
    }

      for (var i = 0; i < patients.length; i++) {
        String score = await fetchSummarySafetyScore(
            "2025-01-01", "2025-10-10", patients.elementAt(i)['accessToken']);
        score = score.split(".")[0];
        scores.add(score);
      }

      setState(() {
        _patientsList = patients;
        _summaryScores = scores;
        _filteredPatientsList = List.from(patients); // Initialize filtered list
        _listOrderedByScore();
      });
    }
  }

  Future<String> fetchSummarySafetyScore(
      String startDate, String endDate, String authToken) async {
    var client = http.Client();
    String statistics = '';
    try {
      var url =
          Uri.parse('https://api.telematicssdk.com/indicators/v2/Scores/safety')
              .replace(queryParameters: {
        'StartDate': startDate,
        'EndDate': endDate,
      });

      final response = await client.get(
        url,
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data["Result"] != null) {
          statistics = data["Result"]["SafetyScore"].toString();
        } else {
          statistics = "0";
        }
      } else {
        print(
            'Failed to fetch daily statistics in physician home screen, status code: ${response.statusCode}, response: ${response.body}');
      }
    } catch (e) {
      print('Error fetching daily statistics: $e');
    } finally {
      client.close();
    }
    setState(() {});
    return statistics;
  }

  void _filterPatientsList() {
    String filter = _filterController.text.toLowerCase();
    List<Map<dynamic, dynamic>> filteredList = _patientsList.where((patient) {
      String email = (patient['email'] ?? '').toLowerCase();
      return email.contains(filter);
    }).toList();

    setState(() {
      _filteredPatientsList = filteredList;
    });
  }

  void _filterSortedPatientsList() {
    String filter = _filterSortedController.text.toLowerCase();
    Map<String, String> map = Map();
    _sortedMap.forEach((key, value) {
      if (key.contains(filter)) {
        // map.addAll(key, value);
        map[key] = value;
      }
    });

    setState(() {
      _sortedPatients = map.keys.toList();
      _sortedScores = map.values.toList();
      // _filteredPatientsList = filteredList;
    });
  }

  void _listOrderedByScore() {
    List<String> emails = [];
    if (_patientsList.isNotEmpty && _summaryScores.isNotEmpty) {
      _patientsList.forEach((element) {
        emails.add(element['email'] + "BREAK" + element['accessToken']);
      });
      var map = Map.fromIterables(emails, _summaryScores);
      var mapEntries = map.entries.toList()
        ..sort((a, b) => (int.tryParse(a.value) ?? 0).compareTo((int.tryParse(b.value) ?? 0)));
      map.clear();
      map.addEntries(mapEntries);
      setState(() {
        _sortedPatients = map.keys.toList();
        _sortedScores = map.values.toList();
        _sortedMap = map;
      });
    }
  }

  Widget _buildPatientsSortedList() {
    return ListView.builder(
      itemCount: _sortedPatients.length,
      itemBuilder: (context, index) {
        String email = _sortedPatients[index].split("BREAK")[0];
        String token = _sortedPatients[index].split("BREAK")[1];
        String score = _sortedScores[index];
        Color tileColor = Colors.white;
        print('Raw score: $score');
        int s = int.tryParse(score) ?? 0;
        print('Parsed score: ' + s.toString());
        if (s >= 80 && s < 101) {
          tileColor = Color.fromARGB(255, 95, 158, 210);
        } else if (s >= 60 && s < 80) {
          tileColor = Color.fromARGB(255, 106, 121, 134);
        } else if (s >= 1 && s < 60) {
          tileColor = Color.fromARGB(255, 250, 38, 38);
        }
        ;
        return new ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.person),
            title: Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Summary Safety Score: ${score}"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PatientDisplayScreen(email, token)));
            },
            shape: Border(
              top: BorderSide(color: const Color.fromARGB(255, 98, 96, 96)),
            ));
      },
    );
  }

  Widget _buildPatientsList() {
  return SizedBox(height: 300,
    child: SingleChildScrollView(
      child: Column(
        children: List.generate(_filteredPatientsList.length, (index) {
          var patient = _filteredPatientsList[index];
          String score = _summaryScores.elementAt(index);
          String email = patient['email'] ?? 'No email';
          String token = patient['accessToken'];
          Color tileColor = Colors.white;
      
          print('Raw score: ${score}');
          int s = int.tryParse(score) ?? 0;
          print('Parsed Score: ${s}');
          
          if (s >= 80 && s < 101) {
            tileColor = Color.fromARGB(255, 95, 158, 210);
          } else if (s >= 60 && s < 80) {
            tileColor = Color.fromARGB(255, 106, 121, 134);
          } else if (s >= 1 && s < 60) {
            tileColor = Color.fromARGB(255, 250, 38, 38);
          }
      
          return ListTile(
            tileColor: tileColor,
            leading: Icon(Icons.person),
            title: Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Summary Safety Score: ${score}"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PatientDisplayScreen(email, token)));
            },
            shape: Border(
              top: BorderSide(color: const Color.fromARGB(255, 98, 96, 96)),
            ),
          );
        }),
      ),
    ),
  );
}


  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsScreen()));
      }
    });
  }

  

  Widget _bottomNav() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Color.fromARGB(255, 103, 139, 183),
      onTap: _onItemTapped,
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _filterController,
        cursorColor: Color.fromARGB(255, 103, 139, 183),
        decoration: InputDecoration(
          labelText: 'Search by patient email', // Updated placeholder text
          labelStyle: TextStyle(
            color: Color.fromARGB(255, 103, 139, 183),
          ),
          suffixIcon: Icon(Icons.search),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 103, 139, 183)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 103, 139, 183)),
          ),
        ),
      ),
    );
  }

  Widget _sortedSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _filterSortedController,
        cursorColor: Color.fromARGB(255, 103, 139, 183),
        decoration: InputDecoration(
          labelText: 'Search by patient email', // Updated placeholder text
          labelStyle: TextStyle(
            color: Color.fromARGB(255, 103, 139, 183),
          ),
          suffixIcon: Icon(Icons.search),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 103, 139, 183)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 103, 139, 183)),
          ),
        ),
      ),
    );
  }

  Widget _sortMenu() {
    return Padding(
      padding: const EdgeInsets.only(left: 180.0),
      child: DropdownButton(
        // Initial Value
        value: dropdownvalue,
        icon: const Icon(Icons.sort),
        // Array list of items
        items: items.map((String items) {
          return DropdownMenuItem(
            value: items,
            child: Text(items),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            dropdownvalue = newValue!;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('HOME'),
      actions: [
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Tutorial()),
            );
          },
        ),
      ],
    ),
    body: Column(
      children: [
        _sortMenu(),
        SizedBox(height: 10),  // Add spacing between the sort menu and search bar
        if (dropdownvalue == "Sort by email") ...[
          _searchBar(),
          SizedBox(height: 10),  // Add space between the search bar and the list
          Expanded(child: _buildPatientsList()),  // Wrap ListView with Expanded
        ] else ...[
          _sortedSearchBar(),
          SizedBox(height: 10),  // Add space between the search bar and the list
          Expanded(child: _buildPatientsSortedList()),  // Wrap ListView with Expanded
        ],
      ],
    ),
    bottomNavigationBar: _bottomNav(),
  );
}

}
